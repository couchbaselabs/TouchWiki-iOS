# TouchWiki For iOS

This is a fairly large demo of [CouchbaseLite][TOUCHDB]. It's an iPad-only viewer and editor app for a wiki that lives in a database. The wiki functionality is pretty basic, but allows you to view and edit pages (in Markdown format) and link between them. It even supports multiple wiki namespaces.

The schema is compatible with the HTML5 ([PhoneGap][TOUCHGAP]) wiki demo app, so the two apps can interoperate on the same database. There is also a companion app server for use with the [Couchbase Sync Gateway][GATEWAY] that enables access control so that multiple users can have their own private or shared wikis.

## How To Build It

1. Clone/checkout this repository.
2. Install the submodule (the Markdown parser) by running `git submodule update --recursive` from within the checked-out repository directory.
3. Obtain a recent build of [_the `public_api` branch_ of CouchbaseLite for iOS][PUBLICAPI], and copy `CouchbaseLite.framework` into the `Frameworks` subdirectory of this repo.
4. Open `TouchWiki.xcodeproj` in Xcode.
5. Build and run.
6. ...
7. Profit!

## Issues & Limitations

* Currently the only form of authentication it supports is [BrowserID][BROWSERID] (aka Persona). That is, if the replication fails with a 401 status, the app will respond by popping up a BrowserID login panel. This should be user-configurable in the sync popup, so it can present a traditional username/password panel instead.
* The UI shows the owner and member status as part of a wiki page, when they're actually attributes of the wiki. It's not clear that changing the member list of a page actually changes it for all pages in that wiki!

## Document Schema

The database contains two types of documents: wikis and pages. Both contain some common properties, as in this example:

    "type": "page",
    "created_at": "2012-12-09T06:05:55.031Z",
    "updated_at": "2012-12-16T01:33:01.909Z"
    "markdown": "# Introduction\n\nThis page is _very_ important...",

* The `type` property indicates which type of document this is, either `"wiki"` or `"page"`.
* `created_at` is a JSON timestamp of the time the document was created.
* `updated_at` is the time the document was last updated by a user.
* `markdown` contains rich-text content in Markdown format; either the body of a page, or a description of a wiki. It's optional in a wiki (and actually unused in the iOS app.)

### Wiki documents

A wiki document's additional properties look like this:

    "_id": "5737529525067657",
    "title": "Mobile Dev",
    "owner_id": "snej"
    "members": ["jchris", "mschoch"],

* The `_id` property is a UUID: It's important that it be unique, but it doesn't need to be human-readable.
* `title` is the user-visible title as a plain-text (not Markdown) string.
* `owner_id` is the user ID of the owner of the wiki.
* `members` is an optional array of user IDs of other people who have access to the wiki and its documents.

### Page documents

    "_id":          "5737529525067657:Sync Client",
    "wiki_id":      "5737529525067657",

* The `_id` property consists of the owning wiki's `_id` plus a colon (":") plus the user-visible name of the page.
* `wiki_id` is the owning wiki's ID; this is redundant with the `_id` but is present so that map functions can access it more quickly.

The reason the page name is stored directly in the document ID, instead of in a property, is to make wiki links efficient: when rendering an HTML page, the app can take the name of the destination page from the wiki link and construct the URL without having to do any database queries.

## Application Code Overview

### Object Model

The application's object model is based on CouchModel. 

* The abstract class `WikiItem` declares the common properties and contains a bit of code to manage them.
* `Wiki` inherits from `WikiItem`. It manages the wiki-specific properties, and contains methods to create pages and to get a list of all pages or their titles.
* `WikiPage` also inherits from `WikiItem`. It knows how to look up the parent `Wiki` object by deriving its ID.
* `WikiStore` is a singleton; actually there is one per wiki database, but there's only one database. It acts as the parent of all wikis and includes methods for creating and enumerating wikis.

#### Drafts

`WikiPage` has an interesting persistent property named `draft` that isn't in the official schema; it's actually private to this app. This property allows edited documents to be saved to local storage, without making the changes publicly visible yet. There are actually three stages to editing:

1. User edits the text onscreen. Each keystroke changes the in-memory `WikiPage.markdown` property, and also sets the `draft` property to `true`.
2. After a delay, or when the app is switched out, the page object autosaves to the local database. But the presence of the `draft` property causes the replication filter to skip this document revision when syncing.
3. Finally, when the user presses the Save button the `draft` property is removed and the page is saved again. Now the replicator will push the change to the server.

This is a pretty useful technique for any application where a database is shared between multiple users, and users want to be able to make local changes without having them immediately visible to others. (A simpler way is to push only on user request, but that causes _all_ local changes to be pushed; using a `draft` property gives the user more fine-grained control.)

### Sync UI

The app includes some classes for managing the user interface for syncing. These are intended to be reuseable, and might eventually end up in CouchbaseLite itself.

**SyncManager** is a thin wrapper around CBLDatabase's sync API that manages a pair of replications to and from a server. It supports a delegate object that can customize replication objects and will be notified of the progress of replication.

**SyncButton** is a UI front-end for sync. It's a `UIBarButtonItem` that can be put in the app's nav bar or toolbar. It displays a "cloud" icon that represents the current state of sync. Right now the appearance is fairly crude, but it does show a progress bar during replication, and highlights the icon if there's an error. Tapping the button opens a pop-up window that lets the user configure sync: there's a text field for the remote database URL, a slider to enable continuous syncing, and a button to trigger a manual sync. It also displays a brief error message if sync failed.

### App UI Controllers

The rest of the app code is a hopefully-straightforward set of iOS UI controllers.

**AppDelegate** is the application delegate; it just initializes CouchbaseLite and constructs the app's top-level UI components.

**PageController** manages the primary window contents: the display of the current page, the navigation bar, and the split-view that overlays the page list. This is the biggest class in the app since it does several different things; it might be refactored in the future.

**WikiListController** controls the top-level table view that lists all wikis, using a `CBLUITableSource`

**PageListController** controls the second-level table view that lists all pages in the currently selected wiki, also using a `CBLUITableSource`.

**PageEditController** runs the editable-text view that's overlaid on the PageController while a page is being edited.

[TOUCHDB]: http://touchdb.org
[TOUCHGAP]: https://github.com/jchris/TouchGap
[GATEWAY]: https://github.com/couchbaselabs/sync_gateway
[PUBLICAPI]: https://github.com/couchbaselabs/CouchbaseLite-iOS/tree/public-api
[BROWSERID]: https://developer.mozilla.org/en-US/docs/persona

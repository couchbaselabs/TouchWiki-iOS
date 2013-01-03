//
//  Wiki.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiItem.h"
@class WikiStore, WikiPage;


/** One wiki in the database. */
@interface Wiki : WikiItem

- (id) initNewWithTitle: (NSString*)title inWikiStore: (WikiStore*)wikiStore;

@property (readonly) NSString* wikiID;

@property (readwrite) NSString* title;

@property (readonly) TDLiveQuery* allPagesQuery;

- (WikiPage*) pageWithTitle: (NSString*)pageTitle;
- (WikiPage*) newPageWithTitle: (NSString*)pageTitle;

- (NSString*) docIDForPageWithTitle: (NSString*)title;

@end


/*  A wiki root document in JSON form:
    {
        "_id": "5737529525067657",
        "_rev": "29-d3aad012fc362578e8a9b652918f419d",
        "type": "wiki",
        "wiki_id" : "5737529525067657",
        "title": "Mobile Dev",
        "tags": "Mobile, Dev, Couchbase",
        "members": "@jchris @snej @mschoch",
        "markdown": "Topics in Mobile!\n\n- HostedCouchbase\n- AccessControl\n- SyncProtocol\n- DeveloperFlow\n- CouchbaseServer\n",
        "created_at": "2012-12-09T06:05:55.031Z",
        "updated_at": "2012-12-16T01:33:01.909Z"
    }
*/
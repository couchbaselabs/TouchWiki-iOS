//
//  WikiPage.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiItem.h"
@class Wiki;


/** A wiki page. */
@interface WikiPage : WikiItem

- (id) initNewWithTitle: (NSString*)title inWiki: (Wiki*)wiki;

@property (readonly) Wiki* wiki;

// Ephemeral properties:
@property bool editing;
@property NSRange selectedRange;

+ (bool) parseDocID: (NSString*)docID
         intoWikiID: (NSString**)outWikiID
           andTitle: (NSString**)outTitle;

@end


/*  Example of a wiki page in JSON form.
    The _id is the owning wiki's _id plus a ":" plus the page title.
    {
        "_id":          "5737529525067657:SyncClient",
        "_rev":         "1-38e911c6b80834e1d21c580a0ab04913",
        "type":         "page",
        "wiki_id":      "5737529525067657",
        "markdown":     "This page is a PlaceHolder"
        "created_at":   "2012-12-09T06:55:47.539Z",
        "updated_at":   "2012-12-16T01:33:01.909Z"
    }
*/

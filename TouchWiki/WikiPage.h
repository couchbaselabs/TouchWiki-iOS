//
//  WikiPage.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <TouchDB/TouchDB.h>


/** A wiki page. */
@interface WikiPage : TDModel

- (id) initWithTitle: (NSString*)title
          inDatabase: (TDDatabase*)db;

@property (readonly) NSString* title;

@property (copy) NSString* markdown;
@property (strong) NSDate* created_at;
@property (strong) NSDate* updated_at;

@property (copy) NSArray* tags;
@property (copy) NSArray* members;

// Ephemeral properties:
@property bool editing;
@property NSRange selectedRange;

+ (NSString*) docIDForTitle: (NSString*)title;
+ (NSString*) titleFromDocID: (NSString*)docID;

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

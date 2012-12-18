//
//  Wiki.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TouchDB/TouchDB.h>
@class WikiStore, WikiPage;


/** One wiki in the database. */
@interface Wiki : NSObject

- (id) initWithStore: (WikiStore*)store ID: (NSString*)wikiID;

@property (readonly) WikiStore* store;
@property (readonly) TDDatabase* database;

@property (readonly) TDLiveQuery* allPagesQuery;

- (WikiPage*) pageWithID: (NSString*)pageID;
- (WikiPage*) pageWithTitle: (NSString*)pageTitle;
- (WikiPage*) newPageWithTitle: (NSString*)pageTitle;

@end

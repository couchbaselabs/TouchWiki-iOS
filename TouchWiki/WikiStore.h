//
//  WikiStore.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/18/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TouchDB/TouchDB.h>
@class Wiki, WikiPage;


/** Wiki interface to a TouchDB database. This is the root of the object model. */
@interface WikiStore : NSObject

- (id) initWithDatabase: (TDDatabase*)database;

+ (WikiStore*) sharedInstance;

@property (readonly) TDDatabase* database;

@property (readonly) TDLiveQuery* allWikisQuery;

- (Wiki*) wikiWithTitle: (NSString*)title;

- (Wiki*) newWikiWithTitle: (NSString*)title;

- (WikiPage*) pageWithID: (NSString*)pageID;

@property (strong) NSString* username;

@end

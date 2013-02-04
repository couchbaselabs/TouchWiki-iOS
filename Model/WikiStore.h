//
//  WikiStore.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/18/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
@class Wiki, WikiPage;


/** Wiki interface to a CouchbaseLite database. This is the root of the object model. */
@interface WikiStore : NSObject

- (id) initWithDatabase: (CBLDatabase*)database;

+ (WikiStore*) sharedInstance;

@property (readonly) CBLDatabase* database;

@property (readonly) CBLLiveQuery* allWikisQuery;

- (Wiki*) wikiWithTitle: (NSString*)title;

- (Wiki*) newWikiWithTitle: (NSString*)title;

- (WikiPage*) pageWithID: (NSString*)pageID;

@property (strong) NSString* username;

@end

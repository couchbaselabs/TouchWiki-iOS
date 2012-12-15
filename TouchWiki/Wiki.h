//
//  Wiki.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TouchDB/TouchDB.h>
@class WikiPage;


@interface Wiki : NSObject

- (id) initWithDatabase: (TDDatabase*)database;

@property (readonly) TDDatabase* database;

@property (readonly) TDLiveQuery* allPagesQuery;

- (WikiPage*) pageWithID: (NSString*)pageID;
- (WikiPage*) newPage;

@end

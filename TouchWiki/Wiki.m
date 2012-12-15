//
//  Wiki.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "Wiki.h"
#import "WikiPage.h"


@implementation Wiki


- (id) initWithDatabase: (TDDatabase*)database {
    self = [super init];
    if (self) {
        _database = database;

        [[_database viewNamed: @"pagesByTitle"] setMapBlock: MAPBLOCK({
            id title = [doc objectForKey: @"title"];
            if (title) emit(title, nil);
        }) reduceBlock: nil version: @"1"];
        _allPagesQuery = [[[_database viewNamed: @"pagesByTitle"] query] asLiveQuery];
    }
    return self;
}


- (WikiPage*) pageWithID: (NSString*)pageID {
    TDDocument* doc = [_database documentWithID: pageID];
    if (!doc.currentRevisionID)
        return nil;
    return [WikiPage modelForDocument: doc];
}


- (WikiPage*) newPage {
    return [[WikiPage alloc] initWithNewDocumentInDatabase: _database];
}


@end

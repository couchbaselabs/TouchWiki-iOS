//
//  Wiki.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "Wiki.h"
#import "WikiStore.h"
#import "WikiPage.h"
#import <TouchDB/TDModelFactory.h>


@implementation Wiki

- (id) initWithStore: (WikiStore*)store ID: (NSString*)wikiID {
    self = [super init];
    if (self) {
        _store = store;

        [[_store.database viewNamed: @"pagesByTitle"] setMapBlock: MAPBLOCK({
            if ([doc[@"type"] isEqualToString: @"page"]) {
                NSString* title = [WikiPage titleFromDocID: doc[@"_id"]];
                if (title)
                    emit(title, nil);
            }
        }) reduceBlock: nil version: @"2"];
        _allPagesQuery = [[[_database viewNamed: @"pagesByTitle"] query] asLiveQuery];
    }
    return self;
}


- (WikiPage*) pageWithID: (NSString*)pageID {
    TDDocument* doc = [_store.database documentWithID: pageID];
    if (!doc.currentRevisionID)
        return nil;
    return [WikiPage modelForDocument: doc];
}


- (WikiPage*) pageWithTitle: (NSString*)title {
    return [self pageWithID: [WikiPage docIDForTitle: title]];
}


- (WikiPage*) newPageWithTitle: (NSString*)pageTitle {
    return [[WikiPage alloc] initWithTitle: pageTitle inDatabase: _database];
}


@end

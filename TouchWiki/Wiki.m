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
{
    TDLiveQuery* _allPagesQuery;
}

@dynamic title, markdown, created_at, updated_at;


- (id) initNewWithTitle: (NSString*)title inDatabase: (TDDatabase*)db {
    self = [super initWithNewDocumentInDatabase: db];
    if (self) {
        [self setValue: @"wiki" ofProperty: @"type"];
        self.title = title;
        self.created_at = self.updated_at = [NSDate date];
    }
    return self;
}


- (NSString*) wikiID {
    return self.document.documentID;
}


- (NSString*) docIDForPageWithTitle: (NSString*)title {
    return [NSString stringWithFormat: @"%@:%@", self.wikiID, title];
}


- (WikiPage*) pageWithTitle: (NSString*)title {
    NSString* pageID = [self docIDForPageWithTitle: title];
    TDDocument* doc = [self.database documentWithID: pageID];
    if (!doc.currentRevisionID)
        return nil;
    return [WikiPage modelForDocument: doc];
}


- (WikiPage*) newPageWithTitle: (NSString*)pageTitle {
    return [[WikiPage alloc] initNewWithTitle: pageTitle inWiki: self];
}


- (TDLiveQuery*) allPagesQuery {
    if (!_allPagesQuery) {
        TDQuery* query = [[self.database viewNamed: @"pagesByTitle"] query];
        query.startKey = @[self.wikiID];
        query.endKey = @[self.wikiID, @{}];
        _allPagesQuery = [query asLiveQuery];
    }
    return _allPagesQuery;
}


@end

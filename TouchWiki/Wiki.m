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
    NSSet* _allPageTitles;
}

@dynamic title, markdown, created_at, updated_at, owner_id, members;


- (id) initNewWithTitle: (NSString*)title inWikiStore: (WikiStore*)wikiStore {
    self = [super initWithNewDocumentInDatabase: wikiStore.database];
    if (self) {
        [self setupType: @"wiki"];
        [self setValue: wikiStore.username ofProperty: @"owner_id"];
        self.title = title;
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
        [_allPagesQuery addObserver: self forKeyPath: @"rows" options: 0 context: NULL];
    }
    return _allPagesQuery;
}


- (NSSet*) allPageTitles {
    if (!_allPageTitles) {
        NSMutableSet* titles = [NSMutableSet set];
        for (TDQueryRow* row in self.allPagesQuery.rows) {
            NSArray* key = row.key;
            [titles addObject: key[1]];
        }
        _allPageTitles = [titles copy];
    }
    return _allPageTitles;
}


- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if (object == _allPagesQuery)
        _allPageTitles = nil;
}


- (bool) editable {
    NSString* username = self.wikiStore.username;
    return [self.owner_id isEqualToString: username] || [self.members containsObject: username];
}


- (bool) owned {
    NSString* username = self.wikiStore.username;
    return [self.owner_id isEqualToString: username];
}


- (void) addMembers: (NSArray*)newMembers {
    NSArray* oldMembers = self.members;
    if (!oldMembers) {
        self.members = newMembers;
        return;
    }
    NSMutableOrderedSet* members = [NSMutableOrderedSet orderedSetWithArray: self.members];
    [members addObjectsFromArray: newMembers];
    self.members = members.array;
}


@end

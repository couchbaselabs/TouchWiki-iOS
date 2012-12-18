//
//  WikiStore.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/18/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiStore.h"
#import "Wiki.h"
#import "WikiPage.h"
#import <TOuchDB/TDModelFactory.h>


@implementation WikiStore


- (id) initWithDatabase: (TDDatabase*)database {
    self = [super init];
    if (self) {
        _database = database;
        [_database.modelFactory registerClass: [Wiki class] forDocumentType: @"wiki"];
        [_database.modelFactory registerClass: [WikiPage class] forDocumentType: @"page"];
    }
    return self;
}


@end

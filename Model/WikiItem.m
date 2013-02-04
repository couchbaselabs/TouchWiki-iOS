//
//  WikiItem.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/18/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiItem.h"
#import "WikiStore.h"


@implementation WikiItem


@dynamic title, markdown, created_at, updated_at;


- (id) initWithDocument: (CBLDocument*)document {
    self = [super initWithDocument: document];
    if (self) {
        self.autosaves = true;
    }
    return self;
}


- (void) setupType: (NSString*)type {
    [self setValue: type ofProperty: @"type"];
    self.created_at = self.updated_at = [NSDate date];
}


- (NSDictionary*) propertiesToSave {
    if (self.needsSave) {
        // Bump the updated_at date when saving:
        NSDate* now = [NSDate date];
        self.updated_at = now;
        if (!self.created_at)
            self.created_at = now;
    }
    return [super propertiesToSave];
}


- (WikiStore*) wikiStore {
    return [WikiStore sharedInstance];
}


- (bool) editable {
    return false; // abstract
}


- (bool) owned {
    return false; // abstract
}


@end

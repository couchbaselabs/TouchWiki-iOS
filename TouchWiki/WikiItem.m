//
//  WikiItem.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/18/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiItem.h"
#import "WikiStore.h"


@interface WikiItem ()
@property (readwrite) NSString* owner_id;
@end


@implementation WikiItem


@dynamic title, markdown, created_at, updated_at, owner_id, members;


- (void) setType: (NSString*)type owner: (NSString*)owner {
    NSParameterAssert(owner.length > 0);
    [self setValue: type ofProperty: @"type"];
    self.owner_id = owner;
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
    NSString* username = self.wikiStore.username;
    return [self.owner_id isEqualToString: username] || [self.members containsObject: username];
}


- (bool) owned {
    NSString* username = self.wikiStore.username;
    return [self.owner_id isEqualToString: username];
}


@end

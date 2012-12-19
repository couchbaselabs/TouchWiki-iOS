//
//  WikiItem.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/18/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiItem.h"

@implementation WikiItem


@dynamic title, markdown, created_at, updated_at, tags, members;


- (NSDictionary*) propertiesToSave {
    if (self.needsSave) {
        NSDate* now = [NSDate date];
        self.updated_at = now;
        if (!self.created_at)
            self.created_at = now;
    }
    return [super propertiesToSave];
}


@end

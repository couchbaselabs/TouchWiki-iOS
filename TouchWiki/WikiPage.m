//
//  WikiPage.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiPage.h"

@implementation WikiPage

@dynamic title, markdown, updated_at, tags, members;

- (bool) untitled {
    return self.title.length == 0;
}

- (NSString*) displayTitle {
    return self.untitled ? NSLocalizedString(@"untitled", @"untitled") : self.title;
}

@end

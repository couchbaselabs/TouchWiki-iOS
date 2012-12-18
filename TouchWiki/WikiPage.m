//
//  WikiPage.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiPage.h"

@implementation WikiPage

@dynamic markdown, created_at, updated_at, tags, members;

- (id) initWithTitle: (NSString*)title inDatabase: (TDDatabase*)db {
    TDDocument* doc = [db documentWithID: [[self class] docIDForTitle: title]];
    self = [super initWithDocument: doc];
    if (self) {
        [self setValue: @"page" ofProperty: @"type"];
        self.created_at = self.updated_at = [NSDate date];
    }
    return self;
}


- (NSString*) title {
    return [[self class] titleFromDocID: self.document.documentID];
}


- (NSDictionary*) propertiesToSave {
    if (self.needsSave)
        self.updated_at = [NSDate date];
    return [super propertiesToSave];
}


+ (NSString*) docIDForTitle: (NSString*)title {
    return [@"wiki:" stringByAppendingString: title];
}

+ (NSString*) titleFromDocID: (NSString*)docID {
    NSRange colon = [docID rangeOfString: @":"];
    if (colon.length == 0)
        return nil;
    if (![[docID substringToIndex: colon.location] isEqualToString: @"wiki"])
        return nil;
    return [docID substringFromIndex: NSMaxRange(colon)];
}


@end

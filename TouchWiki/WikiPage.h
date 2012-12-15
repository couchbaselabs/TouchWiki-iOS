//
//  WikiPage.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <TouchDB/TouchDB.h>


@interface WikiPage : TDModel

@property (copy) NSString* title;
@property (copy) NSString* markdown;
@property (strong) NSDate* updated_at;

@property (copy) NSArray* tags;
@property (copy) NSArray* members;

@end

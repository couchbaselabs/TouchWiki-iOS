//
//  WikiItem.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/18/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <TouchDB/TouchDB.h>

/** Common base class of Wiki and WikiPage. */
@interface WikiItem : TDModel

@property (readonly) NSString* title;
@property (copy) NSString* markdown;

@property (strong) NSDate* created_at;
@property (strong) NSDate* updated_at;

@property (copy) NSArray* tags;
@property (copy) NSArray* members;

@end

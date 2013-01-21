//
//  WikiItem.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/18/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <TouchDB/TouchDB.h>
@class WikiStore;

/** Common base class of Wiki and WikiPage. */
@interface WikiItem : TDModel

@property (readonly) WikiStore* wikiStore;

@property (readonly) NSString* title;
@property (copy) NSString* markdown;

@property (strong) NSDate* created_at;
@property (strong) NSDate* updated_at;

@property (readonly) NSString* owner_id;
@property (copy) NSArray* members;

- (void) addMembers: (NSArray*)newMembers;

@property (readonly) bool editable;
@property (readonly) bool owned;

@end


@interface WikiItem (Private)
- (void) setType: (NSString*)type owner: (NSString*)owner;
@end
//
//  WikiItem.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/18/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <CouchbaseLite/CouchbaseLite.h>
@class WikiStore;

/** Common base class of Wiki and WikiPage. */
@interface WikiItem : CBLModel

@property (readonly) WikiStore* wikiStore;

@property (readonly) NSString* title;
@property (copy) NSString* markdown;

@property (strong) NSDate* created_at;
@property (strong) NSDate* updated_at;

@property (readonly) bool editable;
@property (readonly) bool owned;

@end


@interface WikiItem (Private)
- (void) setupType: (NSString*)type;
@end
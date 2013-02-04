//
//  WindowController.h
//  TouchWiki
//
//  Created by Jens Alfke on 1/30/13.
//  Copyright (c) 2013 Couchbase. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WikiStore;


@interface WindowController : NSWindowController

- (id)initWithWikiStore: (WikiStore*)wikiStore;

@property (readonly) WikiStore* wikiStore;

@end

//
//  WindowController.m
//  TouchWiki
//
//  Created by Jens Alfke on 1/30/13.
//  Copyright (c) 2013 Couchbase. All rights reserved.
//

#import "WindowController.h"
#import <WebKit/WebKit.h>

@implementation WindowController
{
    IBOutlet NSOutlineView* _outline;
    IBOutlet WebView* _webView;
}


- (id)initWithWikiStore: (WikiStore*)wikiStore {
    self = [super initWithWindowNibName: @"WikiWindow"];
    if (self) {
        _wikiStore = wikiStore;
    }
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
}

@end

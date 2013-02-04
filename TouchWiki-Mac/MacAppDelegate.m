//
//  MacAppDelegate.m
//  TouchWiki-Mac
//
//  Created by Jens Alfke on 1/30/13.
//  Copyright (c) 2013 Couchbase. All rights reserved.
//

#import "MacAppDelegate.h"
#import "WindowController.h"
#import "WikiStore.h"
#import <CouchbaseLite/CouchbaseLite.h>


@implementation MacAppDelegate
{
    WindowController* _mainWindow;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initialize CouchbaseLite:
    NSError* error;
    CBLDatabase* database = [[CBLManager sharedInstance] createDatabaseNamed: @"wiki2"
                                                                       error: &error];
    if (!database) {
        NSRunCriticalAlertPanel(@"Fatal Error", @"Couldn't open the database", @"Sorry", nil, nil);
        exit(0);
    }

    // Initialize data model:
    WikiStore* wikiStore = [[WikiStore alloc] initWithDatabase: database];

    // Initialize UI:
    _mainWindow = [[WindowController alloc] initWithWikiStore: wikiStore];
    [_mainWindow showWindow: self];
}

@end

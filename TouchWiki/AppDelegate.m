//
//  AppDelegate.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "AppDelegate.h"
#import "WikiListController.h"
#import "PageListController.h"
#import "PageController.h"
#import "Wiki.h"
#import "WikiStore.h"
#import <CouchbaseLite/CouchbaseLite.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    gAppDelegate = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Initialize CouchbaseLite:
    NSError* error;
    CBLDatabase* database = [[CBLManager sharedInstance] databaseNamed: @"wiki2"
                                                                 error: &error];
    if (!database)
        [self showAlert: @"Couldn't open database" error: error fatal: YES];

    // Initialize data model:
    _wikiStore = [[WikiStore alloc] initWithDatabase: database];

    // Create the UI:
    WikiListController *wikiListController = [[WikiListController alloc]
                                                                initWithWikiStore: _wikiStore];
    PageListController *pageListController = [[PageListController alloc]
                                                                initWithWikiStore: _wikiStore];
    UINavigationController *tableNavController = [[UINavigationController alloc] initWithRootViewController:wikiListController];

    PageController *pageController = [[PageController alloc] initWithWikiStore: _wikiStore];
    UINavigationController *pageNavController = [[UINavigationController alloc] initWithRootViewController:pageController];

    wikiListController.pageListController = pageListController;
    wikiListController.pageController = pageController;
    pageListController.pageController = pageController;
    pageController.pageListController = pageListController;

    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = pageController;
    self.splitViewController.viewControllers = @[tableNavController, pageNavController];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark - ALERT:


// Display an error alert, without blocking.
// If 'fatal' is true, the app will quit when it's pressed.
- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal {
    if (error) {
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedDescription];
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: (fatal ? @"Fatal Error" : @"Error")
                                                    message: message
                                                   delegate: (fatal ? self : nil)
                                          cancelButtonTitle: (fatal ? @"Quit" : @"Sorry")
                                          otherButtonTitles: nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    exit(0);
}

@end

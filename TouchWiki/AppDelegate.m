//
//  AppDelegate.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "AppDelegate.h"
#import "PageListController.h"
#import "PageController.h"
#import "Wiki.h"
#import "WikiStore.h"
#import <TouchDB/TouchDB.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    gAppDelegate = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Initialize TouchDB:
    NSError* error;
    TDDatabase* database = [[TDDatabaseManager sharedInstance] createDatabaseNamed: @"wiki2"
                                                                             error: &error];
    if (!database)
        [self showAlert: @"Couldn't open database" error: error fatal: YES];

    // Initialize data model:
    _wikiStore = [[WikiStore alloc] initWithDatabase: database];

    // Create the UI:
    PageListController *pageListController = [[PageListController alloc] initWithWikiStore: _wikiStore];
    UINavigationController *pageListNavController = [[UINavigationController alloc] initWithRootViewController:pageListController];

    PageController *pageController = [[PageController alloc] initWithWikiStore: _wikiStore];
    UINavigationController *pageNavController = [[UINavigationController alloc] initWithRootViewController:pageController];

    pageListController.pageController = pageController;
    pageController.pageListController = pageListController;

    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = pageController;
    self.splitViewController.viewControllers = @[pageListNavController, pageNavController];
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

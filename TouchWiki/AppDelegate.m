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
#import <TouchDB/TouchDB.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    // Initialize TouchDB:
    NSError* error;
    TDDatabase* database = [[TDDatabaseManager sharedInstance] createDatabaseNamed: @"wiki"
                                                                             error: &error];
    if (!database)
        [self showAlert: @"Couldn't open database" error: error fatal: YES];
    _wiki = [[Wiki alloc] initWithDatabase: database];

    PageListController *pageListController = [[PageListController alloc] initWithNibName:@"PageListController" bundle:nil];
    pageListController.wiki = _wiki;
    UINavigationController *pageListNavController = [[UINavigationController alloc] initWithRootViewController:pageListController];

    PageController *pageController = [[PageController alloc] initWithNibName:@"PageController" bundle:nil];
    UINavigationController *pageNavController = [[UINavigationController alloc] initWithRootViewController:pageController];

    pageListController.pageController = pageController;

    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = pageController;
    self.splitViewController.viewControllers = @[pageListNavController, pageNavController];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    return YES;
}


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

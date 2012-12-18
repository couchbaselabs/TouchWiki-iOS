//
//  AppDelegate.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WikiStore, Wiki;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly) WikiStore* wikiStore;
@property (readonly) Wiki* wiki;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UISplitViewController *splitViewController;

- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal;

@end

AppDelegate* gAppDelegate;

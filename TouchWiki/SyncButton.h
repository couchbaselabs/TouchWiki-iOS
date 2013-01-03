//
//  SyncButton.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/20/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SyncManager;


/** A nav-bar/toolbar button that displays sync status and when touched opens a popover for configuring sync. */
@interface SyncButton : UIBarButtonItem

@property (strong) SyncManager* syncManager;

- (IBAction) configureSync: (id)sender;

@end


/** The controller for the popover invoked by the SyncButton. */
@interface SyncPopoverController : UIViewController <UIPopoverControllerDelegate>
- (id) initWithSyncManager: (SyncManager*)syncManager;
- (IBAction) syncNow:(id)sender;
@property UIPopoverController* popover;
- (void) updateUI;
@end

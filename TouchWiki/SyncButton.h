//
//  SyncButton.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/20/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SyncManager;

@interface SyncButton : UIBarButtonItem

@property (strong) SyncManager* syncManager;


- (IBAction) configureSync: (id)sender;

@end


@interface SyncPopoverController : UIViewController <UIPopoverControllerDelegate>
- (id) initWithSyncManager: (SyncManager*)syncManager;
- (IBAction) syncNow:(id)sender;
@property UIPopoverController* popover;
- (void) updateUI;
@end

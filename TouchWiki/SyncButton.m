//
//  SyncButton.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/20/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "SyncButton.h"
#import "SyncManager.h"
#import "Util.h"


@implementation SyncButton
{
    SyncManager* _syncManager;
    bool _showingIcon;
    bool _showingProgress;
    UIPopoverController* _syncPopover;
}


- (id) initWithCoder: (NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        if (self.action == nil) {
            self.target = self;
            self.action = @selector(configureSync:);
            [self showSyncButton];
        }
    }
    return self;
}


- (SyncManager*) syncManager {
    return _syncManager;
}


- (void) setSyncManager: (SyncManager *)syncManager {
    if (syncManager != _syncManager) {
        if (syncManager) {
            [[NSNotificationCenter defaultCenter] removeObserver: self
                                                            name: SyncManagerStateChangedNotification
                                                          object: syncManager];
        }
        _syncManager = syncManager;
        if (_syncManager) {
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(syncChanged:)
                                                         name: SyncManagerStateChangedNotification
                                                          object: syncManager];
        }
        [self syncChanged: nil];
        self.enabled = (_syncManager != nil) && _showingIcon;
    }
}


- (void) syncChanged: (NSNotification*)n {
    if (n)
        NSLog(@"SyncButton: active=%d, progress = %f", _syncManager.active, _syncManager.progress);//TEMP
    if (_syncManager.active)
        [self showSyncStatus];
    else
        [self showSyncButton];
    [(SyncPopoverController*)_syncPopover.delegate updateUI];
}


- (void) showSyncButton {
    if (!_showingIcon) {
        _showingIcon = true;
        _showingProgress = false;
        NSString* iconName = _syncManager.error ? @"Sync-error.png" : @"Sync.png";
        self.customView = ButtonWithImageNamed(iconName, self, @selector(configureSync:));
        self.enabled = (_syncManager != nil);
    }
}


- (void) showSyncStatus {
    if (!_showingProgress) {
        _showingProgress = true;
        _showingIcon = false;
        UIProgressView* progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progress.frame = self.customView.frame;
        self.customView = progress;
        self.enabled = NO;
    }
    ((UIProgressView*)self.customView).progress = _syncManager.progress;
}


- (IBAction) configureSync: (id)sender {
    if (!_syncPopover) {
        SyncPopoverController* controller = [[SyncPopoverController alloc] initWithSyncManager: _syncManager];
        _syncPopover = [[UIPopoverController alloc] initWithContentViewController: controller];
        controller.popover = _syncPopover;
        _syncPopover.delegate = controller;
        _syncPopover.popoverContentSize = controller.view.frame.size;
        //_syncPopover.delegate = self;
    }
	// If the popover is already showing from the bar button item, dismiss it. Otherwise, present it.
	if (!_syncPopover.popoverVisible) {
		[_syncPopover presentPopoverFromBarButtonItem: self
                             permittedArrowDirections: UIPopoverArrowDirectionAny
                                             animated: YES];
	} else {
		[_syncPopover dismissPopoverAnimated:YES];
        [(SyncPopoverController*)_syncPopover.delegate popoverControllerDidDismissPopover: _syncPopover];
        _syncPopover = nil;
	}
}

@end




@implementation SyncPopoverController
{
    SyncManager* _syncManager;
    IBOutlet UIButton* _syncNowButton;
    IBOutlet UISwitch* _onOffSwitch;
    IBOutlet UITextField* _urlField;
    IBOutlet UILabel* _errorLabel;
}

- (id) initWithSyncManager: (SyncManager*)syncManager {
    self = [super initWithNibName: @"SyncPopover" bundle: nil];
    if (self) {
        _syncManager = syncManager;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void) viewDidLoad {
    _urlField.text = _syncManager.syncURL.absoluteString;
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(urlChanged:)
                                                 name: UITextFieldTextDidChangeNotification
                                               object: _urlField];
    [self updateUI];
}


- (void) updateUI {
    BOOL hasURL = _urlField.text.length > 0;
    _onOffSwitch.enabled = hasURL;
    _syncNowButton.enabled = hasURL && !_onOffSwitch.on && !_syncManager.active;

    NSString* message;
    if (_syncManager.error) {
        message = _syncManager.error.localizedDescription;
    } else switch (_syncManager.mode) {
        case kTDReplicationOffline:
            message = @"Offline (can’t reach server)";
            break;
        case kTDReplicationIdle:
            message = @"In sync";
            break;
        case kTDReplicationActive:
            message = [NSString stringWithFormat: @"Syncing (%.0f%% done)",
                       _syncManager.progress * 100.0];
            break;
        default:
            message = nil;
            break;
    }
    _errorLabel.text = message;
    _errorLabel.textColor = _syncManager.error ? [UIColor redColor] : [UIColor whiteColor];
}


- (void) makeItSo {
    NSString* urlStr = _urlField.text;
    NSURL* url = urlStr.length ? [NSURL URLWithString: urlStr] : nil;
    _syncManager.syncURL = url;
    _syncManager.continuous = _onOffSwitch.on;
}


- (IBAction) toggleOnOff: (id)sender {
    [self updateUI];
}


- (void) urlChanged: (NSNotification*)n {
    [self updateUI];
}


- (IBAction) syncNow: (id)sender {
    [self makeItSo];
    [_syncManager syncNow];
    //[_popover dismissPopoverAnimated: YES];
    //[self popoverControllerDidDismissPopover: _popover];
}


- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self makeItSo];
}


@end

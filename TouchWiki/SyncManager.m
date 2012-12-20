//
//  SyncManager.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/19/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "SyncManager.h"

@implementation SyncManager
{
    TDReplication* _push;
    TDReplication* _pull;
    bool _showingSyncButton;
    UIProgressView* _progress;
}


- (id) init {
    self = [super init];
    if (self) {
        _statusItem = [[UIBarButtonItem alloc] init];
    }
    return self;
}


- (IBAction)configureSync:(id)sender {
}


- (void)updateSyncURL {
    if (!_database)
        return;
    NSURL* newRemoteURL = nil;
    NSString *urlStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"SyncURL"];
    if (urlStr.length > 0)
        newRemoteURL = [NSURL URLWithString:urlStr];

    [self forgetSync];

    NSArray* repls = [self.database replicateWithURL: newRemoteURL exclusively: YES];
    if (repls) {
        _pull = [repls objectAtIndex: 0];
        _push = [repls objectAtIndex: 1];
        NSNotificationCenter* nctr = [NSNotificationCenter defaultCenter];
        [nctr addObserver: self selector: @selector(replicationProgress:)
                     name: kTDReplicationChangeNotification object: _pull];
        [nctr addObserver: self selector: @selector(replicationProgress:)
                     name: kTDReplicationChangeNotification object: _push];
    }
}


- (void) forgetSync {
    NSNotificationCenter* nctr = [NSNotificationCenter defaultCenter];
    if (_pull) {
        [nctr removeObserver: self name: nil object: _pull];
        _pull = nil;
    }
    if (_push) {
        [nctr removeObserver: self name: nil object: _push];
        _push = nil;
    }
}


- (void) replicationProgress: (NSNotificationCenter*)n {
    if (_pull.mode == kTDReplicationActive || _push.mode == kTDReplicationActive) {
        unsigned completed = _pull.completed + _push.completed;
        unsigned total = _pull.total + _push.total;
        NSLog(@"SYNC progress: %u / %u", completed, total);
        [self showSyncStatus];
        _progress.progress = (completed / (float)MAX(total, 1u));
    } else {
        [self showSyncButton];
    }
}


- (void)showSyncButton {
    if (!_showingSyncButton) {
        _showingSyncButton = YES;
        _statusItem.style = UIBarButtonItemStylePlain;
        _statusItem.title = @"Configure"; //FIX: I18N
        _statusItem.customView = nil;
        _statusItem.enabled = YES;
        _statusItem.action = @selector(configureSync:);
    }
}


- (void)showSyncStatus {
    if (_showingSyncButton) {
        _showingSyncButton = NO;
        if (!_progress) {
            _progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
            CGRect frame = _progress.frame;
            frame.size.width = 75.0;    //FIX: Don't hardcode
            _progress.frame = frame;
        }
        _statusItem.customView = _progress;
        _statusItem.enabled = NO;
    }
}


@end

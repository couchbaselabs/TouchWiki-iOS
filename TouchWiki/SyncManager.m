//
//  SyncManager.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/19/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "SyncManager.h"
#import "LoginController.h"


NSString* const SyncManagerStateChangedNotification = @"SyncManagerStateChanged";


@implementation SyncManager
{
    NSMutableArray* _replications;
    bool _showingSyncButton;
    __weak id<SyncManagerDelegate> _delegate;
    LoginController* _loginController;
}


- (id) initWithDatabase: (TDDatabase*)db {
    NSParameterAssert(db);
    self = [super init];
    if (self) {
        _database = db;
        _replications = [[NSMutableArray alloc] init];
        [self addReplications: db.allReplications];
    }
    return self;
}


@synthesize delegate=_delegate, replications=_replications;


- (void) addReplication: (TDReplication*)repl {
    if (![_replications containsObject: repl]) {
        [_replications addObject: repl];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(replicationProgress:)
                                                     name: kTDReplicationChangeNotification
                                                   object: repl];
        if (!_syncURL)
            _syncURL = repl.remoteURL;
        if (repl.continuous)
            _continuous = true;
        if ([_delegate respondsToSelector: @selector(syncManager:addedReplication:)])
            [_delegate syncManager: self addedReplication: repl];
    }
}


- (void) addReplications: (NSArray*)replications {
    for (TDReplication* repl in replications) {
        [self addReplication: repl];
    }
}


- (void) forgetReplication: (TDReplication*)repl {
    [_replications removeObject: repl];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kTDReplicationChangeNotification
                                                  object: repl];
}


- (void) forgetAll {
    for (TDReplication* repl in _replications) {
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: kTDReplicationChangeNotification
                                                      object: repl];
    }
    _replications = [[NSMutableArray alloc] init];
    _syncURL = nil;
}


- (void) setSyncURL: (NSURL*)url {
    if (url == _syncURL || [url isEqual: _syncURL])
        return;
    [self forgetAll];
    if (url) {
        for (TDReplication* repl in [self.database replicateWithURL: url exclusively: YES]) {
            repl.persistent = YES;
            repl.continuous = _continuous;
            [self addReplication: repl];
        }
    }
}


- (void) setContinuous:(bool)continuous {
    _continuous = continuous;
    for (TDReplication* repl in _replications)
        repl.continuous = continuous;
}


- (void) setUsername: (NSString*)username password: (NSString*)password {
    _loginController = nil;
    NSURLCredential* cred = [NSURLCredential credentialWithUser: username
                                                       password: password
                                                    persistence: NSURLCredentialPersistencePermanent];
    for (TDReplication* repl in _replications) {
        repl.credential = cred;
    }
}


- (void) loginCanceled {
    _loginController = nil;
}


- (void) syncNow {
    for (TDReplication* repl in _replications) {
        if (!repl.continuous)
            [repl start];
    }
}


- (void) replicationProgress: (NSNotificationCenter*)n {
    bool active = false;
    unsigned completed = 0, total = 0;
    TDReplicationMode mode = kTDReplicationStopped;
    NSError* error = nil;
    for (TDReplication* repl in _replications) {
        mode = MAX(mode, repl.mode);
        if (!error)
            error = repl.error;
        if (repl.mode == kTDReplicationActive) {
            active = true;
            _completed += repl.completed;
            _total += repl.total;
        }
    }

    if (error != _error && error.code == 401) {
        // Auth needed (or auth is incorrect). See if the delegate wants to do its own auth;
        // otherwise put up a username/password login panel:
        if (![_delegate respondsToSelector: @selector(syncManagerShouldPromptForLogin:)] ||
                [_delegate syncManagerShouldPromptForLogin: self]) {
            if (!_loginController) {
                NSString* user = [_replications[0] credential].user;
                _loginController = [[LoginController alloc] initWithURL: self.syncURL username: user];
                _loginController.delegate = self;
                [_loginController run];
            }
            error = nil;
        }
    }

    if (active != _active || completed != _completed || total != _total || mode != _mode
                          || error != _error) {
        _active = active;
        _completed = completed;
        _total = total;
        _progress = (completed / (float)MAX(total, 1u));
        _mode = mode;
        _error = error;
        NSLog(@"SYNCMGR: active=%d; mode=%d; %u/%u; %@",
              active, mode, completed, total, error.localizedDescription); //FIX: temporary logging
        if ([_delegate respondsToSelector: @selector(syncManagerProgressChanged:)])
            [_delegate syncManagerProgressChanged: self];
        [[NSNotificationCenter defaultCenter]
                                        postNotificationName: SyncManagerStateChangedNotification
                                                      object: self];
    }
}


@end

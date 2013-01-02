//
//  SyncManager.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/19/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <TouchDB/TouchDB.h>


@interface SyncManager : NSObject

- (id) initWithDatabase: (TDDatabase*)database;

@property (readonly) TDDatabase* database;

@property (nonatomic) NSURL* syncURL;
@property (nonatomic) bool continuous;

// These are not KVO-observable; observe SyncManagerStateChangedNotification instead
@property (nonatomic, readonly) unsigned completed, total;
@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) bool active;
@property (nonatomic, readonly) TDReplicationMode mode;
@property (nonatomic, readonly) NSError* error;

- (void) syncNow;

@end


extern NSString* const SyncManagerStateChangedNotification;

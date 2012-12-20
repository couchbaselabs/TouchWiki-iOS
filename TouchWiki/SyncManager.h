//
//  SyncManager.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/19/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TouchDB/TouchDB.h>


@interface SyncManager : NSObject

@property TDDatabase* database;

- (IBAction)configureSync:(id)sender;

@property (readonly) UIBarButtonItem* statusItem;

@end

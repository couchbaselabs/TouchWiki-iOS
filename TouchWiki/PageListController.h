//
//  MasterViewController.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TouchDB/TDUITableSource.h>
@class PageController, Wiki;


@interface PageListController : UIViewController <TouchUITableDelegate>

@property (strong, nonatomic) PageController *pageController;

@property (strong, nonatomic) Wiki* wiki;

@end

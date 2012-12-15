//
//  DetailViewController.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WikiPage;

@interface PageController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) WikiPage* page;

@end

//
//  PageController.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/15/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PageListController, WikiPage;


@interface PageController : UIViewController <UISplitViewControllerDelegate>

@property (strong) PageListController* pageListController;
@property (strong, nonatomic) WikiPage* page;

@end

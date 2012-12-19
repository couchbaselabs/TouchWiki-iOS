//
//  PageController.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/15/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PageListController, WikiStore, WikiPage;


@interface PageController : UIViewController <UISplitViewControllerDelegate>

- (id)initWithWikiStore: (WikiStore*)wikiStore;

@property (strong) PageListController* pageListController;
@property (strong, nonatomic) WikiPage* page;

- (IBAction) showEditor: (id)sender;
- (IBAction) hideEditor: (id)sender;
- (IBAction) saveChanges: (id)sender;

@end

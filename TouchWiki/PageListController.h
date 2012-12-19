//
//  PageListController.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TouchDB/TDUITableSource.h>
@class PageController, WikiStore, Wiki, WikiPage;


@interface PageListController : UIViewController <TouchUITableDelegate>

- (id)initWithWikiStore: (WikiStore*)wikiStore;

@property (strong, nonatomic) PageController *pageController;

@property (readonly, nonatomic) WikiStore* wikiStore;

- (bool) selectPage: (WikiPage*)page;

- (void) createPageWithTitle: (NSString*)title;

@end

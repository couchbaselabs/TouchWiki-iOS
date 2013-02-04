//
//  WikiListController.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/19/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CBLUITableSource.h>
@class PageListController, PageController, WikiStore, Wiki;


@interface WikiListController : UIViewController <CBLUITableDelegate>

- (id)initWithWikiStore: (WikiStore*)wikiStore;

@property (strong, nonatomic) PageListController *pageListController;
@property (strong, nonatomic) PageController *pageController;

@property (readonly, nonatomic) WikiStore* wikiStore;

- (bool) selectWiki: (Wiki*)wiki;

- (void) createWikiWithTitle: (NSString*)title;

@end

//
//  PageListController.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "PageListController.h"
#import "PageController.h"
#import "Wiki.h"
#import "WikiPage.h"
#import <TouchDB/TouchDB.h>


@implementation PageListController
{
    IBOutlet TDUITableSource* _dataSource;
}


- (id)init {
    self = [super initWithNibName:@"PageListController" bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Pages", @"Pages");
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    return self;
}
							
- (void)viewDidLoad {
    [super viewDidLoad];

    _dataSource.query = _wiki.allPagesQuery;
    _dataSource.deletionAllowed = YES;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                             target:self
                                                             action:@selector(newPage:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - ACTIONS:


- (IBAction) newPage: (id)sender {
    WikiPage* page = [_wiki newPage];
    page.updated_at = [NSDate date];
    
    NSError* error;
    BOOL ok = [page save: &error];
    NSAssert(ok, @"Couldn't save new page: %@", error);

    self.pageController.page = page;
}


#pragma mark - TABLE DELEGATE:


- (WikiPage*) pageForRow: (TDQueryRow*)row {
    return [WikiPage modelForDocument: row.document];
}


- (void)couchTableSource:(TDUITableSource*)source
             willUseCell:(UITableViewCell*)cell
                  forRow:(TDQueryRow*)row
{
    cell.textLabel.text = [self pageForRow: row].displayTitle;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TDDocument* doc = [_dataSource documentAtIndexPath: indexPath];
    WikiPage* page = [WikiPage modelForDocument: doc];
    self.pageController.page = page;
}

@end

//
//  PageListController.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "PageListController.h"
#import "PageController.h"
#import "AppDelegate.h"
#import "Wiki.h"
#import "WikiPage.h"
#import <TouchDB/TouchDB.h>


@implementation PageListController
{
    IBOutlet TDUITableSource* _dataSource;
}


- (id)initWithWiki: (Wiki*)wiki {
    self = [super initWithNibName:@"PageListController" bundle:nil];
    if (self) {
        _wiki = wiki;
        self.title = NSLocalizedString(@"Pages", @"Pages");
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        self.restorationIdentifier = @"PageListController";
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

    [_pageController addObserver: self forKeyPath: @"page" options: 0 context: NULL];
    [self selectPage: _pageController.page];
}


#pragma mark - ACTIONS:


- (void) createPageWithTitle: (NSString*)title {
    WikiPage* page = [_wiki newPageWithTitle: title];
    NSError* error;
    if (![page save: &error]) {
        [gAppDelegate showAlert: @"Couldn't create page" error: error fatal: NO];
    }

    _pageController.page = page;
    [_pageController showEditor: self];
}

    
- (IBAction) newPage: (id)sender {
    //FIX: This is an awful UI.
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Create Page"
                                                    message: @"What's the title of the new page?"
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alert {
    return [alert textFieldAtIndex: 0].text.length > 0;
}

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex > 0) {
        NSString* title = [alert textFieldAtIndex: 0].text;
        if (title.length > 0)
            [self createPageWithTitle: title];
    }
}


- (bool) selectPage: (WikiPage*)page {
    NSIndexPath* path = page ? [_dataSource indexPathForDocument: page.document] : nil;
    if (!path)
        return false;
    [_dataSource.tableView selectRowAtIndexPath: path
                                       animated: NO
                                 scrollPosition: UITableViewScrollPositionMiddle];
    if (page != _pageController.page) {
        _pageController.page = page;
    }
    return true;
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == _pageController && [keyPath isEqualToString: @"page"])
        [self selectPage: _pageController.page];
}


#pragma mark - TABLE DELEGATE:


- (WikiPage*) pageForRow: (TDQueryRow*)row {
    return [WikiPage modelForDocument: row.document];
}


- (void)couchTableSource:(TDUITableSource*)source
             willUseCell:(UITableViewCell*)cell
                  forRow:(TDQueryRow*)row
{
    cell.textLabel.text = [self pageForRow: row].title;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TDDocument* doc = [_dataSource documentAtIndexPath: indexPath];
    WikiPage* page = [WikiPage modelForDocument: doc];
    self.pageController.page = page;
}

@end

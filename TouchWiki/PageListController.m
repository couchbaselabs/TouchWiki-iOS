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
#import "WikiStore.h"
#import "Wiki.h"
#import "WikiPage.h"
#import <TouchDB/TouchDB.h>


@implementation PageListController
{
    IBOutlet UITableView* _table;
    IBOutlet TDUITableSource* _dataSource;
    UIBarButtonItem* _newPageButton;
    Wiki* _wiki;
}


- (id)initWithWikiStore: (WikiStore*)wikiStore {
    self = [super initWithNibName:@"PageListController" bundle:nil];
    if (self) {
        _wikiStore = wikiStore;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        self.restorationIdentifier = @"PageListController";
        [self addObserver: self forKeyPath: @"pageController.page" options: 0 context: NULL];
    }
    return self;
}
							
- (void)viewDidLoad {
    [super viewDidLoad];

    _dataSource.deletionAllowed = YES;
    
    _newPageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(newPage:)];
    self.navigationItem.rightBarButtonItem = _newPageButton;

    [self showWiki];

    [self selectPage: _pageController.page];
}


- (void)viewWillAppear:(BOOL)animated {
    //FIX: This isn't good enough in landscape mode, where the view is always visible.
    [self updateCells];
}


- (Wiki*) wiki {
    return _wiki;
}


- (void) setWiki:(Wiki *)wiki {
    if (wiki == _wiki)
        return;
    _wiki = wiki;
    [self showWiki];
}


- (void) showWiki {
    _dataSource.query = _wiki.allPagesQuery;
    self.title = _wiki.title;
    _newPageButton.enabled = _wiki.editable;
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
    NSString* title = [NSString stringWithFormat: @"New Page In “%@”", _wiki.title];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: @"What's the title of the new page?"
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* titleField = [alert textFieldAtIndex: 0];
    titleField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    titleField.returnKeyType = UIReturnKeyDone;
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
    Wiki* wiki = page.wiki;
    if (wiki != _wiki) {
        self.wiki = wiki;
    }
    if (_dataSource) {
        NSIndexPath* path = page ? [_dataSource indexPathForDocument: page.document] : nil;
        if (path)
            [_dataSource.tableView selectRowAtIndexPath: path
                                               animated: NO
                                         scrollPosition: UITableViewScrollPositionMiddle];
    }
    if (page != _pageController.page) {
        _pageController.page = page;
    }
    return true;
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString: @"pageController.page"]) {
        [self selectPage: _pageController.page];
    }
}


#pragma mark - TABLE DELEGATE:


- (WikiPage*) pageForRow: (TDQueryRow*)row {
    return [WikiPage modelForDocument: row.document];
}

- (WikiPage*) pageForPath: (NSIndexPath*)indexPath {
    TDDocument* doc = [_dataSource documentAtIndexPath: indexPath];
    return [WikiPage modelForDocument: doc];
}



- (void)couchTableSource:(TDUITableSource*)source
             willUseCell:(UITableViewCell*)cell
                  forRow:(TDQueryRow*)row
{
    WikiPage* page = [self pageForRow: row];
    cell.textLabel.text = page.title;
    cell.imageView.image = [UIImage imageNamed: @"PageIcon"];
    [cell.imageView sizeToFit];
    [self updateCell: cell forPage: page];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.pageController.page = [self pageForPath: indexPath];
}


- (void) updateCells {
    for (UITableViewCell* cell in _table.visibleCells) {
        WikiPage* page = [self pageForPath: [_table indexPathForCell: cell]];
        [self updateCell: cell forPage: page];
    }
}


- (void) updateCell: (UITableViewCell*)cell forPage: (WikiPage*)page {
    UIImageView* accessory = (UIImageView*)cell.accessoryView;
    if (!page.draft) {
        accessory.image = nil;
    } else if (accessory) {
        accessory.image = [UIImage imageNamed: @"EditedIcon"];
    } else {
        UIImage* editedImage = [UIImage imageNamed: @"EditedIcon"];
        cell.accessoryView = [[UIImageView alloc] initWithImage: editedImage];
    }
}


@end

//
//  WikiListController.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/19/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiListController.h"
#import "PageListController.h"
#import "PageController.h"
#import "AppDelegate.h"
#import "WikiStore.h"
#import "Wiki.h"
#import <TouchDB/TouchDB.h>


@implementation WikiListController
{
    IBOutlet UITableView* _table;
    IBOutlet TDUITableSource* _dataSource;
}


- (id)initWithWikiStore: (WikiStore*)wikiStore {
    self = [super initWithNibName:@"PageListController" bundle:nil];
    if (self) {
        _wikiStore = wikiStore;

        self.title = @"Wikis";
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        self.restorationIdentifier = @"WikiListController";
        [self addObserver: self forKeyPath: @"pageListController.wiki" options: 0 context: NULL];
    }
    return self;
}
							
- (void)viewDidLoad {
    [super viewDidLoad];

    _dataSource.query = _wikiStore.allWikisQuery;
    _dataSource.deletionAllowed = YES;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                             target:self
                                                             action:@selector(newWiki:)];
    self.navigationItem.rightBarButtonItem = addButton;

    Wiki* wiki = _pageListController.wiki;
    [self selectWiki: wiki];
    if (wiki)
        [self.navigationController pushViewController: _pageListController animated: NO];
}


#pragma mark - ACTIONS:


- (void) createWikiWithTitle: (NSString*)title {
    Wiki* wiki = [_wikiStore newWikiWithTitle: title];
    NSError* error;
    if (![wiki save: &error]) {
        [gAppDelegate showAlert: @"Couldn't create wiki" error: error fatal: NO];
    }

    _pageListController.wiki = wiki;
}

    
- (IBAction) newWiki: (id)sender {
    NSString* title = [NSString stringWithFormat: @"Create A New Wiki"];
    UIAlertView* alert;
    if (!_wikiStore.username) {
        alert = [[UIAlertView alloc] initWithTitle: title
                                           message: @"Please log in and sync first."
                                          delegate: self
                                 cancelButtonTitle: @"Login"
                                 otherButtonTitles: nil];
    } else {
        //FIX: This is an awful UI.
        alert = [[UIAlertView alloc] initWithTitle: title
                                           message: @"What's the title of the new wiki?"
                                          delegate: self
                                 cancelButtonTitle: @"Cancel"
                                 otherButtonTitles: @"Create", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField* titleField = [alert textFieldAtIndex: 0];
        titleField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        titleField.returnKeyType = UIReturnKeyDone;
    }
    [alert show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alert {
    return [alert textFieldAtIndex: 0].text.length > 0;
}

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_wikiStore.username) {
        if (buttonIndex > 0) {
            NSString* title = [alert textFieldAtIndex: 0].text;
            if (title.length > 0)
                [self createWikiWithTitle: title];
        }
    } else {
        [_pageController configureSync];
    }
}


- (bool) selectWiki: (Wiki*)wiki {
    NSIndexPath* path = wiki ? [_dataSource indexPathForDocument: wiki.document] : nil;
    if (!path)
        return false;
    [_dataSource.tableView selectRowAtIndexPath: path
                                       animated: NO
                                 scrollPosition: UITableViewScrollPositionMiddle];
    if (wiki != _pageListController.wiki) {
        _pageListController.wiki = wiki;
    }
    return true;
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString: @"pageListController.wiki"])
        [self selectWiki: _pageListController.wiki];
}


#pragma mark - TABLE DELEGATE:


- (Wiki*) wikiForRow: (TDQueryRow*)row {
    return [Wiki modelForDocument: row.document];
}


- (void)couchTableSource:(TDUITableSource*)source
             willUseCell:(UITableViewCell*)cell
                  forRow:(TDQueryRow*)row
{
    cell.textLabel.text = [self wikiForRow: row].title;
    cell.imageView.image = [UIImage imageNamed: @"WikiIcon"];
    [cell.imageView sizeToFit];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TDDocument* doc = [_dataSource documentAtIndexPath: indexPath];
    Wiki* wiki = [Wiki modelForDocument: doc];
    _pageListController.wiki = wiki;
    [self.navigationController pushViewController: _pageListController animated: YES];
}

@end

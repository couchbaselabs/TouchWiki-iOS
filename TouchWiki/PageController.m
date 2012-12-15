//
//  DetailViewController.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "PageController.h"
#import "WikiPage.h"


@interface PageController ()
{
    IBOutlet UILabel* _titleLabel;
    IBOutlet UITextView* _textView;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end


@implementation PageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Page", @"Page");
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}


- (void)setPage:(id)newPage {
    if (_page != newPage) {
        _page = newPage;
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}


// Display the page in the UI.
- (void)configureView {
    _titleLabel.text = _page.title;
    _textView.text = _page.markdown;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

							
#pragma mark - SPLIT VIEW


- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Pages", @"Pages");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end

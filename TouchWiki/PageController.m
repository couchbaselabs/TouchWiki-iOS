//
//  PageController.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/15/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "PageController.h"
#import "PageEditController.h"
#import "WikiPage.h"
#import "GHMarkdownParser.h"

#define kFlipDuration 0.4
#define kFlipToEditAnimation UIViewAnimationOptionTransitionFlipFromLeft
#define kFlipToPreviewAnimation UIViewAnimationOptionTransitionFlipFromRight


static NSString *sHTMLPrefix, *sHTMLSuffix;


@implementation PageController
{
    IBOutlet UITextField* _titleView;
    IBOutlet UIWebView* _webView;
    IBOutlet UIBarButtonItem* _editButton;
    IBOutlet UIBarButtonItem* _previewButton;
    IBOutlet UIBarButtonItem* _saveButton;
    
    PageEditController* _editController;
    UIPopoverController *_masterPopoverController;
}


+ (void) initialize {
    if (!sHTMLPrefix) {
        NSURL* url = [[NSBundle bundleForClass: self] URLForResource: @"PageTemplate" withExtension: @"html"];
        NSString* html = [NSString stringWithContentsOfURL: url encoding: NSUTF8StringEncoding error: nil];
        NSArray* parts = [html componentsSeparatedByString: @"{{BODY}}"];
        NSAssert(parts.count == 2, @"PageTemplate.html does not contain {{BODY}}");
        sHTMLPrefix = parts[0];
        sHTMLSuffix = parts[1];
    }
}


- (id)init {
    self = [super initWithNibName:@"PageController" bundle:nil];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = _editButton;
    [self configureView];
}


- (void)setPage:(id)newPage {
    if (_page != newPage) {
        [self hideEditor: self];
        _page = newPage;
        [self configureView];
    }

    [_masterPopoverController dismissPopoverAnimated:YES];
}


// Display the page in the UI.
- (void)configureView {
    [self loadContent];
    [self configureButtons];
}


- (void) configureButtons {
    (void)self.view;
    NSArray* buttons = @[_editButton];
    NSString* editTitle = @"Edit";
    BOOL editEnabled = YES;
    if (!_page) {
        // No page at all:
        editEnabled = NO;
    } else if (_editController) {
        // Edit mode:
        buttons = @[_previewButton, _saveButton];
    } else if (_page.editing) {
        // Preview mode:
        editTitle = @"Editing";
    } else {
        // Regular mode:
    }

    _editButton.enabled = editEnabled;
    _editButton.title = editTitle;
    [self.navigationItem setRightBarButtonItems: buttons animated: YES];
}


- (void) loadContent {
    self.title = _page ? _page.displayTitle : NSLocalizedString(@"No Page", @"No Page");
    _titleView.text = _page.title;

    NSString* str = _page.markdown;
    NSString* html = @"";
    if (str.length > 0)
        html = [GHMarkdownParser flavoredHTMLStringFromMarkdownString: str];
    html = [NSString stringWithFormat: @"%@%@%@", sHTMLPrefix, html, sHTMLSuffix];
    [_webView loadHTMLString: html baseURL: nil];
    //NSLog(@"HTML = %@", html);
}


- (IBAction) showEditor: (id)sender {
    if (_editController)
        return;
    // Start editing:
    if (!_page.editing) {
        NSLog(@"*** EDITING '%@'", _page.title);
        _page.editing = YES;
    }
    
    _editController = [[PageEditController alloc] initWithPage: _page];
    [_editController willMoveToParentViewController: self];
    [self addChildViewController: _editController];

    [self configureButtons];

    [UIView transitionWithView: self.view
                      duration: kFlipDuration
                       options: kFlipToEditAnimation
                    animations: ^{ [self.view addSubview: _editController.view]; }
                    completion: nil];
}


- (IBAction) hideEditor: (id)sender {
    if (!_editController)
        return;
    
    if (_page.needsSave)
        [self loadContent];
    else
        _page.editing = NO;
    
    [_editController willMoveToParentViewController: nil];
    [_editController removeFromParentViewController];

    [UIView transitionWithView: self.view
                      duration: kFlipDuration
                       options: kFlipToPreviewAnimation
                    animations: ^{ [_editController.view removeFromSuperview]; }
                    completion: nil];

    _editController = nil;
    [self configureButtons];
}


- (IBAction) saveChanges: (id)sender {
    [_editController saveEditing];
    [self loadContent];
    [self hideEditor: nil];
}


#pragma mark - SPLIT VIEW


- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Pages", @"Pages");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    _masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    _masterPopoverController = nil;
}


@end

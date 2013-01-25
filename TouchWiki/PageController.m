//
//  PageController.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/15/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "PageController.h"
#import "PageEditController.h"
#import "PageListController.h"
#import "AppDelegate.h"
#import "WikiStore.h"
#import "Wiki.h"
#import "WikiPage.h"
#import "SyncManager.h"
#import "SyncButton.h"
#import "Util.h"
#import "BrowserIDController+UIKit.h"
#import "GHMarkdownParser.h"

#define kFlipDuration 0.4
#define kFlipToEditAnimation UIViewAnimationOptionTransitionFlipFromLeft
#define kFlipToPreviewAnimation UIViewAnimationOptionTransitionFlipFromRight


static NSString *sHTMLTemplate;
static NSRegularExpression* sExplicitWikiWordRegex;
static NSRegularExpression* sImplicitWikiWordRegex;


@interface PageController () <SyncManagerDelegate, BrowserIDControllerDelegate>
@end


@implementation PageController
{
    IBOutlet UITextField* _titleView;
    IBOutlet UIWebView* _webView;
    IBOutlet SyncButton* _syncButton;
    IBOutlet UIBarButtonItem* _backButton;
    IBOutlet UIBarButtonItem* _fwdButton;
    IBOutlet UIBarButtonItem* _editButton;
    IBOutlet UIBarButtonItem* _previewButton;
    IBOutlet UIBarButtonItem* _saveButton;

    WikiStore* _wikiStore;
    PageEditController* _editController;
    UIPopoverController *_masterPopoverController;
    NSString* _pendingTitle;
    NSURL* _pendingURL;
    BrowserIDController* _browserIDController;
}


+ (void) initialize {
    if (!sHTMLTemplate) {
        NSURL* url = [[NSBundle bundleForClass: self] URLForResource: @"PageTemplate" withExtension: @"html"];
        sHTMLTemplate = [NSString stringWithContentsOfURL: url encoding: NSUTF8StringEncoding error: nil];
        NSAssert(sHTMLTemplate != nil, @"Can't load PageTemplate.html");

        sExplicitWikiWordRegex =
                    [NSRegularExpression regularExpressionWithPattern: @"\\[\\[([\\w ]+)\\]\\]"
                                                              options: 0
                                                                error: nil];
        NSAssert(sExplicitWikiWordRegex != nil, @"Bad regex");

        sImplicitWikiWordRegex =
            [NSRegularExpression regularExpressionWithPattern: @"\\b[A-Z][a-z]+[A-Z][A-Za-z]*\\b"
                                              options: NSRegularExpressionUseUnicodeWordBoundaries
                                                            error: nil];
        NSAssert(sImplicitWikiWordRegex != nil, @"Bad regex");
    }
}


- (id)initWithWikiStore: (WikiStore*)wikiStore {
    self = [super initWithNibName:@"PageController" bundle:nil];
    if (self) {
        _wikiStore = wikiStore;

        // Restore the current page:
        NSString* curPageID = [[NSUserDefaults standardUserDefaults] stringForKey: @"CurrentPageID"];
        if (curPageID) {
            self.page = [_wikiStore pageWithID: curPageID];
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    _backButton = BarButtonWithImageNamed(@"Triangle-Left.png", self, @selector(goBack:));
    _fwdButton = BarButtonWithImageNamed(@"Triangle-Right.png", self, @selector(goForward:));

    SyncManager* syncMgr = [[SyncManager alloc] initWithDatabase: _wikiStore.database];
    _syncButton.syncManager = syncMgr;
    syncMgr.delegate = self;

    self.navigationItem.rightBarButtonItem = _editButton;
    self.navigationItem.leftBarButtonItems = @[_syncButton, _backButton, _fwdButton];
    [self configureView];
}


- (void) syncManager: (SyncManager*)manager addedReplication: (TDReplication*)replication {
    if (replication.pull) {
        // Pull replication: Define the set of channels to sync
        replication.filter = @"sync_gateway/bychannel";
        replication.query_params = @{@"channels": @"*"};
    } else {
        // Push replication: Set filter to block pushing draft documents
        replication.filter = @"notDraft";   // defined in WikiStore.m
    }
}


- (void) setPage: (WikiPage*)newPage {
    NSLog(@"setPage: %@", newPage);
    if (_page != newPage) {
        [self hideEditor: self];

        [_page removeObserver: self forKeyPath: @"draft"];
        _page = newPage;
        [_page addObserver: self forKeyPath: @"draft" options: 0 context: NULL];
        [self configureView];

        [[NSUserDefaults standardUserDefaults] setObject: _page.document.documentID
                                                  forKey: @"CurrentPageID"];
    }
    [_masterPopoverController dismissPopoverAnimated:YES];
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == _page) {
        [self configureButtons];
    }
}


// Display the page in the UI.
- (void)configureView {
    [self loadContent];
    [self configureButtons];
}


- (void) configureButtons {
    (void)self.view; // make sure nib is loaded

    NSMutableArray* buttons = [NSMutableArray array];
    
    if (_editController) {
        [buttons addObject: _previewButton];
        _previewButton.title = _page.draft ? @"Preview" : @"Done";
    } else {
        [buttons addObject: _editButton];
        _editButton.title = _page.editable ? @"Edit" : @"View Source";
    }
    
    if (_page.draft)
        [buttons addObject: _saveButton];

    [self.navigationItem setRightBarButtonItems: buttons animated: YES];
}


static void replace(NSMutableString* str, NSString* pattern, NSString* replacement) {
    if (!replacement)
        replacement = @"";
    [str replaceOccurrencesOfString: pattern withString: replacement
                            options: 0 range: NSMakeRange(0, str.length)];
}


- (void) loadContent {
    if (!_page) {
        self.title = NSLocalizedString(@"No Page", @"No Page");
        [_webView loadHTMLString: @"" baseURL: nil];
        return;
    }
    
    self.title = [NSString stringWithFormat: @"%@ » %@", _page.wiki.title, _page.title];
    NSMutableString* html = [sHTMLTemplate mutableCopy];

    NSString* klass = _page.owned ? @"owned" : (_page.editable ? @"unlocked" : @"locked");

    //FIX: Use a real template engine!
    replace(html, @"{{ACCESSCLASS}}", klass);
    replace(html, @"{{OWNER}}", _page.wiki.owner_id);
    replace(html, @"{{MEMBERS}}", [_page.wiki.members componentsJoinedByString: @", "]);

    if (_page.draft) {
        [html appendString: @"<div id='banner'>PREVIEW</div>\n"];
    }

    NSMutableString* bodyHTML = [NSMutableString string];
    NSMutableString* markdown = _page.markdown.mutableCopy;
    if (markdown.length > 0) {
        // Markdown parsing:
        [sExplicitWikiWordRegex replaceMatchesInString: markdown options: 0
                                         range: NSMakeRange(0,markdown.length)
                                  withTemplate: @"[$1](wiki:$1)"];

        // Implicit wiki-word matching -- matches all words in CamelCase.
        // Generates a different (unobtrusive) style of link if the word does not match a page.
        NSString* origHTML = [GHMarkdownParser flavoredHTMLStringFromMarkdownString: markdown];
        bodyHTML = [origHTML mutableCopy];
        __block int offset = 0;
        NSSet* titles = _page.wiki.allPageTitles;
        NSString* curTitle = _page.title;
        [sImplicitWikiWordRegex enumerateMatchesInString: origHTML
                                                 options: 0
                                                   range: NSMakeRange(0,markdown.length)
                                              usingBlock:
             ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                 NSRange range = result.range;
                 NSString* word = [origHTML substringWithRange: range];
                 if ([word isEqualToString: curTitle])
                     return;
                 NSString* klass = [titles containsObject: word] ? @"" : @"wikiword";
                 NSString* replacement = [NSString stringWithFormat: @"<a class='%@' href='wiki:%@'>%@</a>",
                                          klass, word, word];
                 range.location += offset;
                 [bodyHTML replaceCharactersInRange: range withString: replacement];
                 offset += replacement.length - range.length;
             }];
    }
    replace(html, @"{{BODY}}", bodyHTML);
    [_webView loadHTMLString: html baseURL: nil];
    //NSLog(@"HTML = %@", html);
}


#pragma mark - ACTIONS:


- (IBAction) showEditor: (id)sender {
    if (_editController)
        return;
    
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
    
    [self loadContent];

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
    [_editController storeText];
    _page.draft = false;

    NSError* error;
    NSLog(@"Saving...");
    if (![_page save: &error]) {
        [gAppDelegate showAlert: @"Couldn't save page" error: error fatal: NO];
        return;
    }
    
    [self loadContent];
    [self hideEditor: nil];
}


#pragma mark - BROWSERID:


- (void) syncManagerProgressChanged: (SyncManager*)manager {
    NSError* error = manager.error;
    NSLog(@"ERROR = %@", error);//TEMP
    if (error && error.code == 401) {   //FIX: Check domain too
        if (!_browserIDController) {
            _browserIDController = [[BrowserIDController alloc] init];
            _browserIDController.origin = [manager.replications[0] browserIDOrigin];
            _browserIDController.delegate = self;
            [_browserIDController presentModalInController: self];
        }
    }
}


- (void) browserIDControllerDidCancel: (BrowserIDController*) browserIDController {
    [_browserIDController.viewController dismissViewControllerAnimated: YES completion: NULL];
    _browserIDController = nil;
}

- (void) browserIDController: (BrowserIDController*) browserIDController
           didFailWithReason: (NSString*) reason
{
    [self browserIDControllerDidCancel: browserIDController];
}

- (void) browserIDController: (BrowserIDController*) browserIDController
     didSucceedWithAssertion: (NSString*) assertion
{
    [self browserIDControllerDidCancel: browserIDController];
    for (TDReplication* repl in _syncButton.syncManager.replications) {
        [repl registerBrowserIDAssertion: assertion];
    }
}



#pragma mark - WEB VIEW


- (void) goToPageNamed: (NSString*)title {
    WikiPage* page = [_page.wiki pageWithTitle: title];
    if (page)
        [_pageListController selectPage: page];
    else {
        _pendingTitle = title;
        NSString* message = [NSString stringWithFormat: @"There is no page named “%@”. "
                                                         "Do you want to create it?", title];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Create Page?"
                                                        message: message
                                                           delegate: self
                                                  cancelButtonTitle: @"Cancel"
                                                  otherButtonTitles: @"Create", nil];
        [alert show];
    }
}

- (void) goToExternalURL: (NSURL*)url {
    _pendingURL = url;
    NSString* message = @"This URL will open in another app. Do you want to open it?";
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Open external URL?"
                                                    message: message
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Open", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex <= 0)
        return;
    if (_pendingURL) {
        [[UIApplication sharedApplication] openURL: _pendingURL];
    } else {
        [_pageListController createPageWithTitle: _pendingTitle];
    }
    _pendingTitle = nil;
    _pendingURL = nil;
}


- (void) updateMembers: (NSArray*)members {
    members = [[NSOrderedSet orderedSetWithArray: members] array];  // Remove duplicates
    _page.wiki.members = members;
    [_page.wiki addMembers: members];
}


- (BOOL)webView:(UIWebView *)webView
        shouldStartLoadWithRequest:(NSURLRequest *)request
        navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = request.URL;
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([url.scheme isEqualToString: @"wiki"]) {
            NSString* title = [url.resourceSpecifier stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSLog(@"Link to '%@'", title);
            [self performSelector: @selector(goToPageNamed:) withObject: title afterDelay: 0.0];
        } else if ([[UIApplication sharedApplication] canOpenURL: url]) {
            [self performSelector: @selector(goToExternalURL:) withObject: url afterDelay: 0.0];
        } else {
            NSString* message = [NSString stringWithFormat: @"Couldn't open URL <%@>", url.absoluteString];
            [gAppDelegate showAlert: message error: nil fatal: NO];
        }
        return NO;

    } else if (navigationType == UIWebViewNavigationTypeOther) {
        if ([url.scheme isEqualToString: @"wikicmd"]) {
            NSArray* items = [url.path componentsSeparatedByString: @"/"];
            NSString* cmd = items[1];
            items = [items subarrayWithRange: NSMakeRange(2, items.count - 2)];
            if ([cmd isEqualToString: @"setMembers"]) {
                [self updateMembers: items];
            } else {
                NSLog(@"Warning: WebView sent unknown command '%@'", cmd);
            }
            return NO;
        }
    }
    return YES;
}


- (IBAction) goBack: (id)sender {
    //[_webView goBack];
}


- (IBAction) goForward: (id)sender {
    //[_webView goForward];
}



#pragma mark - SPLIT VIEW


- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    (void)self.view; // ensure nib is loaded
    barButtonItem.title = NSLocalizedString(@"Pages", @"Pages");

    NSMutableArray* buttons = self.navigationItem.leftBarButtonItems.mutableCopy;
    [buttons insertObject: barButtonItem atIndex: 0];
    self.navigationItem.leftBarButtonItems = buttons;
    _masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    (void)self.view; // ensure nib is loaded
    NSMutableArray* buttons = self.navigationItem.leftBarButtonItems.mutableCopy;
    [buttons removeObject: barButtonItem];
    self.navigationItem.leftBarButtonItems = buttons;
    _masterPopoverController = nil;
}


@end

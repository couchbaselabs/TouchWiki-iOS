//
//  PageEditController.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "PageEditController.h"
#import "WikiPage.h"


@implementation PageEditController
{
    IBOutlet UITextField* _titleView;
    IBOutlet UITextView* _textView;
}


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
}


// Display the page in the UI.
- (void)configureView {
    _titleView.text = _page.title;
    _textView.text = _page.markdown;
    self.title = _page.displayTitle;
    UIView* toEditFirst = _page.untitled ? _titleView : _textView;
    [toEditFirst becomeFirstResponder];
}


- (void) storeText {
    _page.title = _titleView.text;
    _page.markdown = _textView.text;
    NSLog(@"Stored text; changed = %d", _page.needsSave);
}


- (void) saveEditing {
    [self storeText];
    NSError* error;
    NSLog(@"Saving...");
    BOOL saved = [_page save: &error];
    NSAssert(saved, @"Failed to save: %@", error);//FIX: proper error handling
}


#pragma mark - TEXT DELEGATE:


- (IBAction) titleChanged: (id)sender {
    NSLog(@"Title changed");//TEMP
    _page.title = _titleView.text;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_textView becomeFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"Text changed");//TEMP
    _page.markdown = _textView.text;
}


@end

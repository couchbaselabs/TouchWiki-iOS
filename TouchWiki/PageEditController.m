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


- (id) initWithPage: (WikiPage*)page {
    NSParameterAssert(page != nil);
    self = [super init];
    if (self) {
        _page = page;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _titleView.text = _page.title;
    _textView.text = _page.markdown;
    _textView.selectedRange = _page.selectedRange;
    [_textView scrollRangeToVisible: _textView.selectedRange];
    self.title = _page.displayTitle;
    UIView* toEditFirst = _page.untitled ? _titleView : _textView;
    [toEditFirst becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated {
    [self storeText];
    [super viewWillDisappear: animated];
}


- (void) storeText {
    _page.title = _titleView.text;
    _page.markdown = _textView.text;
    _page.selectedRange = _textView.selectedRange;
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
    _page.title = _titleView.text;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_textView becomeFirstResponder];
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    _page.markdown = _textView.text;
}


@end

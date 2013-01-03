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
    IBOutlet UIView* _keypadView;
}


- (id) initWithPage: (WikiPage*)page {
    NSParameterAssert(page != nil);
    self = [super init];
    if (self) {
        _page = page;
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(resizeForKeyboard:)
                                                     name: UIKeyboardWillShowNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(resizeForKeyboard:)
                                                     name: UIKeyboardWillHideNotification
                                                   object: nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _titleView.text = _page.title;
    _titleView.enabled = NO;
    _textView.inputAccessoryView = _keypadView;
    _textView.text = _page.markdown;
    _textView.selectedRange = _page.selectedRange;
    [_textView scrollRangeToVisible: _textView.selectedRange];
    _textView.editable = _page.editable;
    self.title = _page.title;

    if (_textView.editable)
        [_textView becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated {
    [self storeText];
    [super viewWillDisappear: animated];
}


- (void) resizeForKeyboard: (NSNotification*)n {
    CGRect kbdFrame = [(NSValue*)n.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbdFrame = [self.view.window convertRect: kbdFrame fromWindow: nil];
    kbdFrame = [self.view.superview convertRect: kbdFrame fromView: nil];

    CGRect textFrame = self.view.frame;
    textFrame.size.height = kbdFrame.origin.y - textFrame.origin.y;
    self.view.frame = textFrame;
}


- (void) storeText {
    if (_page.editable)
        _page.markdown = _textView.text;
    _page.selectedRange = _textView.selectedRange;
    NSLog(@"Stored text; changed = %d", _page.needsSave);
}


#pragma mark - TEXT EDITING:


#define kOpenDelimiterChars  @"_*`[[<"
#define kCloseDelimiterChars @"_*`]]>"

- (IBAction) specialKey:(id)sender {
    NSString* key = ((UIButton*)sender).titleLabel.text;
    UITextRange *sel = _textView.selectedTextRange;
    NSRange r = [kOpenDelimiterChars rangeOfString: key];
    if (r.length == 0 || sel.isEmpty) {
        [_textView insertText: key];
    } else {
        NSString* endingKey = [kCloseDelimiterChars substringWithRange: r];
        UITextPosition* start = sel.start;
        UITextPosition* end = sel.end;
        [_textView replaceRange: [_textView textRangeFromPosition: end toPosition: end]
                       withText: endingKey];
        [_textView replaceRange: [_textView textRangeFromPosition: start toPosition: start]
                       withText: key];
        start = [_textView positionFromPosition: start offset: key.length];
        end = [_textView positionFromPosition: end offset: key.length];
        _textView.selectedTextRange = [_textView textRangeFromPosition: start toPosition: end];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_textView becomeFirstResponder];
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    _page.markdown = _textView.text;
}


@end

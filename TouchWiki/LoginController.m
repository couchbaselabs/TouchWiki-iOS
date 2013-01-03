//
//  LoginController.m
//  TouchWiki
//
//  Created by Jens Alfke on 1/3/13.
//  Copyright (c) 2013 Couchbase. All rights reserved.
//

#import "LoginController.h"
#import "WikiStore.h"


@implementation LoginController


static LoginController* sLoginController;


- (void) run {
    //FIX: This is a terrible UI.
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Who Are You?"
                                                    message: @"Please enter your hopefully-unique wiki username:"
                                                   delegate: self
                                          cancelButtonTitle: @"Quit"
                                          otherButtonTitles: @"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* titleField = [alert textFieldAtIndex: 0];
    titleField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    titleField.returnKeyType = UIReturnKeyDone;
    [alert show];
    sLoginController = self;
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alert {
    return [alert textFieldAtIndex: 0].text.length > 0;
}


- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString* username = [alert textFieldAtIndex: 0].text;
    sLoginController = nil;
    if (buttonIndex > 0) {
        if (username.length > 0) {
            [WikiStore sharedInstance].username = username;
            return;
        }
    }

    // User canceled:
    exit(0);
}


@end

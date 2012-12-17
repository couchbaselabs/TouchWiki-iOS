//
//  PageEditController.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WikiPage;


@interface PageEditController : UIViewController <UITextViewDelegate>

- (id) initWithPage: (WikiPage*)page;

@property (readonly, nonatomic) WikiPage* page;

- (void) saveEditing;

@end

//
//  Util.h
//  TouchWiki
//
//  Created by Jens Alfke on 12/21/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>

UIButton* ButtonWithImageNamed(NSString* imageName,
                               id target, SEL action);

UIBarButtonItem* BarButtonWithImageNamed(NSString* imageName,
                                         id target, SEL action);

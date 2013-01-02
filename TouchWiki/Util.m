//
//  Util.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/21/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "Util.h"


UIButton* ButtonWithImageNamed(NSString* imageName,
                               id target, SEL action)
{
    UIImage *image = [UIImage imageNamed: imageName];
    NSCAssert(image != nil, @"Couldn't find image '%@'", imageName);
    UIButton* button = [UIButton buttonWithType: UIButtonTypeCustom];
    [button setImage: image forState: UIControlStateNormal];
    button.frame = (CGRect){{0,0}, image.size};
    if (action)
        [button addTarget: target action: action forControlEvents: UIControlEventTouchUpInside];
    return button;
}


UIBarButtonItem* BarButtonWithImageNamed(NSString* imageName,
                                         id target, SEL action)
{
    UIButton* button = ButtonWithImageNamed(imageName, target, action);
    return [[UIBarButtonItem alloc] initWithCustomView: button];
}

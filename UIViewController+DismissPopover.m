//
//  UIViewController+DismissPopover.m
//  Kareo
//
//  Created by Chris Lavender on 11/15/13.
//  Copyright (c) 2013 Kareo. All rights reserved.
//

#import "UIViewController+DismissPopover.h"

#import <objc/runtime.h>

static char PRESENTEDPOPOVERCONTROLLER_KEY;

@implementation UIViewController (DismissPopover)

- (void)dismissPopoverIfApplicable
{
    // don't want to call this on the iPhone
    if ([self respondsToSelector:@selector(dismissPopoverAnimated:)]) {
        if (self.presentedPopoverController.isPopoverVisible) {
            [self.presentedPopoverController dismissPopoverAnimated:NO];
        }
    }
}

- (void)setPresentedPopoverController:(UIPopoverController *)presentedPopoverController
{
    objc_setAssociatedObject(self, &PRESENTEDPOPOVERCONTROLLER_KEY, presentedPopoverController, OBJC_ASSOCIATION_RETAIN);
}

- (UIPopoverController *)presentedPopoverController
{
    return (UIPopoverController *)objc_getAssociatedObject(self, &PRESENTEDPOPOVERCONTROLLER_KEY);
}

@end

//
//  UIViewController+DismissPopover.h
//
//  Created by Chris Lavender on 11/15/13.
//  Copyright (c) 2013 Chris Lavender. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DismissPopover)

- (void)setPresentedPopoverController:(UIPopoverController *)presentedPopoverController;
- (UIPopoverController *)presentedPopoverController;

- (void)dismissPopoverIfApplicable;

@end

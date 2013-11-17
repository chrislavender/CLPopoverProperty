//
//  UIPopoverController+PresentationSwizzle.m
//  UIPopoverDismissTest
//
//  Created by Chris Lavender on 11/16/13.
//  Copyright (c) 2013 Chris Lavender. All rights reserved.
//

#import "UIPopoverController+PresentationSwizzle.h"

#import <objc/runtime.h>
#import "UIViewController+DismissPopover.h"

@interface UIView (GetUIViewController)
- (UIViewController *)firstAvailableUIViewController;
- (id)traverseResponderChainForUIViewController;
@end

void MethodSwizzle(Class c, SEL originalSEL, SEL overrideSEL)
{
    Method originalMethod = class_getInstanceMethod(c, originalSEL);
    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);
    
    if(class_addMethod(c, originalSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        // only the super implements originalSEL
        class_replaceMethod(c, overrideSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    
    } else {
        // the reciever and it's super implement originalSEL
        method_exchangeImplementations(originalMethod, overrideMethod);
    }
}

@implementation UIPopoverController (PresentationSwizzle)

- (void)override_presentPopoverFromRect:(CGRect)arg1
                                 inView:(UIView *)arg2
               permittedArrowDirections:(UIPopoverArrowDirection)arg3
                               animated:(BOOL)arg4
{
    UIViewController *presentingViewController = [arg2 firstAvailableUIViewController];
    
    presentingViewController.presentedPopoverController = self;
    
    [self override_presentPopoverFromRect:arg1
                                   inView:arg2
                 permittedArrowDirections:arg3
                                 animated:arg4];
}

- (void)override_presentPopoverFromBarButtonItem:(UIBarButtonItem *)arg1
                        permittedArrowDirections:(UIPopoverArrowDirection)arg2
                                        animated:(BOOL)arg3
{
    UIViewController *presentingViewController = nil;
    
    if (arg1.customView) {
        presentingViewController = [arg1.customView firstAvailableUIViewController];
        
    } else if ([arg1.target isKindOfClass:UIView.class]) {
        presentingViewController = [(UIView *)arg1.target firstAvailableUIViewController];
        
    } else if ([arg1.target isKindOfClass:UIViewController.class]) {
        presentingViewController = (UIViewController *)arg1.target;
    }
    
    if (presentingViewController) {
        presentingViewController.presentedPopoverController = self;
        
    }
    
    [self override_presentPopoverFromBarButtonItem:arg1
                          permittedArrowDirections:arg2
                                          animated:arg3];
}

+ (void)load {
    MethodSwizzle(self,
                  @selector(presentPopoverFromRect:inView:permittedArrowDirections:animated:),
                  @selector(override_presentPopoverFromRect:inView:permittedArrowDirections:animated:));
    
    MethodSwizzle(self,
                  @selector(presentPopoverFromBarButtonItem:permittedArrowDirections:animated:),
                  @selector(override_presentPopoverFromBarButtonItem:permittedArrowDirections:animated:));
}

@end


@implementation UIView (GetUIViewController)

- (UIViewController *)firstAvailableUIViewController
{
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id)traverseResponderChainForUIViewController
{
    id nextResponder = [self nextResponder];
    
    if ([nextResponder isKindOfClass:UIViewController.class]) {
        return nextResponder;
        
    } else if ([nextResponder isKindOfClass:UIView.class]) {
        return [nextResponder traverseResponderChainForUIViewController];
        
    } else {
        return nil;
        
    }
}

@end
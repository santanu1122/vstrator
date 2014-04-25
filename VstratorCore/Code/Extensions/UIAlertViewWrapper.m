//
//  UIAlertViewWrapper.m
//  VstratorApp
//
//  Created by Mac on 09.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "UIAlertViewWrapper.h"
#import "NSError+Extensions.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

#import <FacebookSDK/NSError+FBError.h>

@implementation UIAlertViewWrapper

#pragma mark - Static Ctor

+ (id)wrapperWithCallback:(Callback)callback
{
    return [self.class wrapperWithCallback:callback errorCallback:nil];
}

#pragma mark - Static alerts

+ (void)alertError:(NSError *)error
{
    [[self.class wrapperWithCallback:nil] alertError:error];
}

+ (void)alertError:(NSError *)error title:(NSString *)title
{
    [[self.class wrapperWithCallback:nil] alertError:error title:title];
}

+ (void)alertString:(NSString *)string
{
    [[self.class wrapperWithCallback:nil] alertString:string];
}

+ (void)alertString:(NSString *)string title:(NSString *)title;
{
    [[self.class wrapperWithCallback:nil] alertString:string title:title];
}

+ (void)alertErrorOrString:(NSError *)error string:(NSString *)string
{
    [[self.class wrapperWithCallback:nil] alertErrorOrString:error string:string];
}

+ (void)alertErrorOrString:(NSError *)error string:(NSString *)string title:(NSString *)title
{
    [[self.class wrapperWithCallback:nil] alertErrorOrString:error string:string title:title];
}

+ (void)alertInvalidInputString:(NSString *)string
{
    [[self.class wrapperWithCallback:nil] alertInvalidInputString:string];
}

#pragma mark - Instance alerts

+ (NSString *)stringWithError:(NSError *)error
{
    NSString *rv = nil;
    if (error.fberrorCategory != FBErrorCategoryInvalid) {
        rv = error.fberrorUserMessage;
        if (rv == nil && error.userInfo != nil && [error.userInfo.allKeys containsObject:@"com.facebook.sdk:ParsedJSONResponseKey"])
            rv = error.userInfo[@"com.facebook.sdk:ParsedJSONResponseKey"][@"body"][@"error"][@"message"];
    }
    if (rv == nil)
        rv = error.localizedDescription;
    return rv;
}

- (void)alertError:(NSError *)error
{
    [self alertString:[self.class stringWithError:error]];
}

- (void)alertError:(NSError *)error title:(NSString *)title
{
    [self alertString:[self.class stringWithError:error] title:title];
}

- (void)alertString:(NSString *)string
{
    [self alertString:string title:VstratorStrings.ErrorGenericTitle];
}

- (void)alertString:(NSString *)string title:(NSString *)title;
{
    [[[UIAlertView alloc] initWithTitle:title 
                                message:string
                               delegate:self 
                      cancelButtonTitle:VstratorConstants.GenericCloseActionName 
                      otherButtonTitles:nil] show];
}

- (void)alertErrorOrString:(NSError *)error string:(NSString *)string
{
    [self alertErrorOrString:error string:string title:VstratorStrings.ErrorGenericTitle];
}

- (void)alertErrorOrString:(NSError *)error string:(NSString *)string title:(NSString *)title
{
    NSAssert(error != nil || string != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    if (error == nil) {
        [self alertString:string title:title];
    } else {
        [self alertError:error title:title];
    }
}

- (void)alertInvalidInputString:(NSString *)string
{
    [self alertString:string title:VstratorStrings.ErrorWrongInputTitle];
}

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    [[[UIAlertView alloc] initWithTitle:title 
                                message:message
                               delegate:self 
                      cancelButtonTitle:cancelButtonTitle 
                      otherButtonTitles:otherButtonTitles, nil] show];
}

#pragma mark - Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.callbackAndReleaseSelf(@(buttonIndex));
}

@end

//
//  TwitterController.h
//  VstratorApp
//
//  Created by Mac on 16.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionSheetSelector.h"
#import "Callbacks.h"

@interface TwitterController : NSObject<ActionSheetSelectorDelegate>

+ (void)checkAccessToAccount:(NSString *)accountIdentity callback:(IdentityCallback)callback;
+ (void)selectAccountInView:(UIView *)view callback:(IdentityCallback)callback;
+ (void)tweet:(NSString *)tweet account:(NSString *)accountIdentity callback:(ErrorCallback)callback;

@end

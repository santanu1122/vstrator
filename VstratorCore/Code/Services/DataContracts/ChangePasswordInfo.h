//
//  ChangePasswordInfo.h
//  VstratorCore
//
//  Created by akupr on 10.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mappable.h"

@interface ChangePasswordInfo : NSObject <Mappable>

@property (nonatomic, copy) NSString* oldPassword;
@property (nonatomic, copy) NSString* password;

@end

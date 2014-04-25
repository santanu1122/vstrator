//
//  FacebookUserInfo.h
//  VstratorApp
//
//  Created by Mac on 16.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookUserInfo : NSObject

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *facebookIdentity;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy, readonly) NSString *name;

- (id)initWithEmail:(NSString *)email
   facebookIdentity:(NSString *)facebookIdentity
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName;

@end

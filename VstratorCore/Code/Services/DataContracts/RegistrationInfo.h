//
//  RegistrationInfo.h
//  VstratorApp
//
//  Created by user on 25.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mappable.h"

@interface RegistrationInfo : NSObject<Mappable>

@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* facebookIdentity;
@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* primarySportName;

-(id) initWithEmail:(NSString *)email
   facebookIdentity:(NSString *)facebookIdentity
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName
           password:(NSString *)password
   primarySportName:(NSString *)primarySportName;

@end

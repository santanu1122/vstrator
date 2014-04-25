//
//  RegistrationInfo.m
//  VstratorApp
//
//  Created by user on 25.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "RegistrationInfo.h"

@implementation RegistrationInfo

@synthesize email = _email;
@synthesize facebookIdentity = _facebookIdentity;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize password = _password;
@synthesize primarySportName = _primarySportName;

-(id) initWithEmail:(NSString *)email
   facebookIdentity:(NSString *)facebookIdentity
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName
           password:(NSString *)password
   primarySportName:(NSString *)primarySportName
{
	self = [self init];
	if (self) {
		self.email = email;
        self.facebookIdentity = facebookIdentity;
		self.firstName = firstName;
		self.lastName = lastName;
		self.password = password;
		self.primarySportName = primarySportName;
	}
	return self;
}

+(RKObjectMapping*) mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RegistrationInfo class]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"firstName": @"firstName",
     @"lastName": @"lastName",
     @"email": @"email",
     @"password": @"password",
     @"primarySport": @"primarySport"}];
	return mapping;
}

+(RKObjectMapping *)serialization
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{
     @"email": @"email",
     @"firstName": @"firstName",
     @"lastName": @"lastName",
     @"facebookIdentity": @"socialMediaId",
     @"password": @"password",
     @"primarySportName": @"primarySport"}];
    return mapping;
}

@end

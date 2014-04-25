//
//  FacebookUserInfo.m
//  VstratorApp
//
//  Created by Mac on 16.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "FacebookUserInfo.h"

@implementation FacebookUserInfo

@synthesize email = _email;
@synthesize facebookIdentity = _facebookIdentity;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName, nil];
}

- (id)initWithEmail:(NSString *)email
   facebookIdentity:(NSString *)facebookIdentity
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName;
{
	self = [self init];
	if (self) {
		self.email = email;
		self.facebookIdentity = facebookIdentity;
		self.firstName = firstName;
		self.lastName = lastName;
	}
	return self;
}

@end

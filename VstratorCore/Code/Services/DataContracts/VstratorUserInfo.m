//
//  VstratorUserInfo.m
//  VstratorApp
//
//  Created by user on 29.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "VstratorUserInfo.h"

@implementation VstratorUserInfo

@synthesize pictureUrl = _pictureUrl;
@synthesize primarySportName = _primarySportName;
@synthesize vstratorIdentity = _vstratorIdentity;
@synthesize vstratorUserName = _vstratorUserName;

- (id)initWithEmail:(NSString *)email
   facebookIdentity:(NSString *)facebookIdentity
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName
         pictureUrl:(NSString *)pictureUrl
   primarySportName:(NSString *)primarySportName
   vstratorIdentity:(NSString *)vstratorIdentity
   vstratorUserName:(NSString *)vstratorUserName
{
	self = [super initWithEmail:email 
               facebookIdentity:facebookIdentity
                      firstName:firstName
                       lastName:lastName];
	if (self) {
        self.pictureUrl = pictureUrl;
		self.primarySportName = primarySportName;
		self.vstratorIdentity = vstratorIdentity;
        self.vstratorUserName = vstratorUserName;
	}
	return self;
}

+(RKObjectMapping*) mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[VstratorUserInfo class]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"socialMediaID": @"facebookIdentity",
     @"firstName": @"firstName",
     @"lastName": @"lastName",
     @"email": @"email",
     @"profilePictureUrl": @"pictureUrl",
     @"primarySport": @"primarySportName",
     @"userKey": @"vstratorIdentity",
     @"userName": @"vstratorUserName"}];
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
     @"primarySportName": @"primarySport",
     @"vstratorIdentity": @"userKey",
     @"vstratorUserName": @"userName"}];
    return mapping;
}

@end

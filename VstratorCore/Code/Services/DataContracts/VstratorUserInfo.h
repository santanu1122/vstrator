//
//  VstratorUserInfo.h
//  VstratorApp
//
//  Created by user on 29.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookUserInfo.h"
#import "Mappable.h"

@interface VstratorUserInfo : FacebookUserInfo<Mappable>

@property (nonatomic, copy) NSString *pictureUrl;
@property (nonatomic, copy) NSString *primarySportName;
@property (nonatomic, copy) NSString *vstratorIdentity;
@property (nonatomic, copy) NSString *vstratorUserName;

- (id)initWithEmail:(NSString *)email
   facebookIdentity:(NSString *)facebookIdentity
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName
         pictureUrl:(NSString *)pictureUrl
   primarySportName:(NSString *)primarySportName
   vstratorIdentity:(NSString *)vstratorIdentity
   vstratorUserName:(NSString *)vstratorUserName;

@end

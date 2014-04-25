//
//  Session.h
//  VstratorCore
//
//  Created by akupr on 08.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Media.h"

@class Clip;

@interface Session : Media

@property (nonatomic, retain) NSNumber * audioFileDuration;
@property (nonatomic, retain) NSString * audioFileName;
@property (nonatomic, retain) NSData * telestrationData;
@property (nonatomic, retain) NSString * url2;
@property (nonatomic, retain) Clip *originalClip;
@property (nonatomic, retain) Clip *originalClip2;

@end

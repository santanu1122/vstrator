//
//  ClipMetaInfo.h
//  VstratorApp
//
//  Created by user on 23.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mappable.h"

@interface ClipMetaInfo : NSObject<Mappable>

@property (nonatomic, copy) NSString* recordingKey; // GUID
@property (nonatomic, copy) NSString* userKey; // GUID
@property (nonatomic, copy) NSString* siteKey; // GUID
@property (nonatomic, copy) NSString* coachKey; // GUID
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* notes;
@property (nonatomic, copy) NSString* sport;
@property (nonatomic, copy) NSString* action;
@property (nonatomic, copy) NSString* originalFileName;
@property (nonatomic, copy) NSString* framesKey; // GUID
@property (nonatomic) BOOL isImage;
@property (nonatomic, copy) NSDate* activityDate;
@property (nonatomic) BOOL notifyAthlete;

@property (nonatomic, readonly) NSString* activityDateFormatted;

@end

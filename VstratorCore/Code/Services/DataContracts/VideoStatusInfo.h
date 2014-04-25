//
//  VideoStatusInfo.h
//  VstratorCore
//
//  Created by akupr on 12.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "Mappable.h"

typedef enum {
    VideoEncodingStatusNotAvailable = -3,
    VideoEncodingStatusError = -2,
    VideoEncodingStatusErrorRetrying = -1,
    VideoEncodingStatusNotStarted = 0,
    VideoEncodingStatusProcessing = 1,
    VideoEncodingStatusReady = 2,
    VideoEncodingStatusUnencodedReady = 3
} VideoEncodingStatus;

typedef enum {
    VideoKeyTypeClip = 0,
    VideoKeyTypeSession = 1,
} VideoKeyType;

@interface VideoStatusInfo : NSObject<Mappable>

@property (nonatomic) VideoKeyType videoKeyType;
@property (nonatomic) VideoEncodingStatus encodingStatus;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSDate* videoDate;
@property (nonatomic, copy) NSString* videoKey;
@property (nonatomic, copy) NSURL* videoURL;

@end

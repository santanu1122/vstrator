//
//  MediaTypeInfo.h
//  VstratorApp
//
//  Created by akupr on 29.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

typedef enum {
    DownloadMediaTypeClips = 0,
    DownloadMediaTypeVstratedClips = 1,
    DownloadMediaTypeExercises = 2,
    DownloadMediaTypeWorkouts = 3,
    DownloadMediaTypeExtras = 4,
    DownloadMediaTypeFeaturedVideos = 5,
} DownloadMediaType;

@interface MediaTypeInfo : NSObject

@property (nonatomic, copy) NSString* applicationId;
@property (nonatomic) DownloadMediaType mediaType;
@property (nonatomic, copy) NSString* title;

+(RKObjectMapping *)mapping;

@end

//
//  DownloadContent+Extensions.h
//  VstratorApp
//
//  Created by akupr on 27.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "DownloadContent.h"

typedef enum {
    DownloadContentStatusNew,
    DownloadContentStatusNotified,
    DownloadContentStatusRequested,
    DownloadContentStatusInProgress,
    DownloadContentStatusFailed,
    DownloadContentStatusCompleeted,
    DownloadContentStatusAll // The last one used only in the requests to MediaService
} DownloadContentStatus;

typedef enum {
    DownloadContentTypeMedia,
    DownloadContentTypeExercise,
    DownloadContentTypeWorkout,
    DownloadContentTypeExtras,
    DownloadContentTypeFeaturedVideos
} DownloadContentType;

@interface DownloadContent (Extensions)

-(void)addToDownloadQueue;

+(DownloadContent*)contentFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context;

@end

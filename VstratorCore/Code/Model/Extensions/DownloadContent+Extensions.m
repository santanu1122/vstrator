//
//  DownloadContent+Extensions.m
//  VstratorApp
//
//  Created by akupr on 27.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "DownloadContent+Extensions.h"
#import "MediaTypeInfo.h"

@implementation DownloadContent (Extensions)

-(void)addToDownloadQueue
{
    if (self.status.intValue < DownloadContentStatusRequested)
        self.status = @(DownloadContentStatusRequested);
}

+(DownloadContent*)contentFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context
{
    DownloadContent* content = [NSEntityDescription insertNewObjectForEntityForName:@"DownloadContent" inManagedObjectContext:context];
    content.identity = [[NSProcessInfo processInfo] globallyUniqueString];
    content.status = @(DownloadContentStatusNew);
    switch ([object[@"MediaType"] intValue]) {
        case DownloadMediaTypeClips:
        case DownloadMediaTypeVstratedClips:
            content.type = @(DownloadContentTypeMedia);
            break;
        case DownloadMediaTypeExercises:
            content.type = @(DownloadContentTypeExercise);
            break;
        case DownloadMediaTypeWorkouts:
            content.type = @(DownloadContentTypeWorkout);
            break;
        case DownloadMediaTypeExtras:
            content.type = @(DownloadContentTypeExtras);
            break;
        case DownloadMediaTypeFeaturedVideos:
            content.type = @(DownloadContentTypeFeaturedVideos);
            break;
    }
    return content;
}

@end

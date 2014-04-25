//
//  ContentSet+Extensions.m
//  VstratorCore
//
//  Created by akupr on 11.02.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ContentSet+Extensions.h"
#import "Media+Extensions.h"
#import "DownloadContent+Extensions.h"

@implementation ContentSet (Extensions)

+(ContentSet *)contentSetFromObject:(NSDictionary*)info inContext:(NSManagedObjectContext*)context error:(NSError **)error
{
    ContentSet* set = [NSEntityDescription insertNewObjectForEntityForName:@"ContentSet" inManagedObjectContext:context];
    set.identity = info[@"ID"];
    set.name = info[@"name"];
    set.notes = info[@"description"];
    set.inAppPurchaseID = info[@"inAppPurchaseID"];
    set.price = [info[@"price"] description];
    set.isPurchased = info[@"isPurchased"];
    return set;
}

-(void)updateWithObject:(NSDictionary *)info
{
    self.isPurchased = info[@"isPurchased"];
    for (NSDictionary* dict in info[@"videos"]) {
        if (dict[@"videoUrl"]) {
            NSSet* filtered = [self.contents filteredSetUsingPredicate:
                               [NSPredicate predicateWithFormat:@"media.videoKey =[cd] %@", dict[@"videoKey"]]];
            Media* media = [[filtered anyObject] media];
            if (!media) {
                NSError* error = nil;
                media = [Media mediaFromObject:dict inContext:self.managedObjectContext error:&error];
                if (error) {
                    NSLog(@"Cannot update media. Error: %@", error);
                } else {
                    media.download = [NSEntityDescription insertNewObjectForEntityForName:@"DownloadContent"
                                                                             inManagedObjectContext:self.managedObjectContext];
                    media.download.identity = [[NSProcessInfo processInfo] globallyUniqueString];
                    media.download.status = @(DownloadContentStatusNew);
                    [self addContentsObject:media.download];
                }
            } else {
                media.publicURL = dict[@"videoUrl"];
            }
        }
    }
}

-(void)downloadAll
{
    for (DownloadContent* content in self.contents) {
        [content addToDownloadQueue];
    }
}

@end

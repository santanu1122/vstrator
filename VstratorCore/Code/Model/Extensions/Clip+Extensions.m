//
//  Clip+Extensions.m
//  VstratorApp
//
//  Created by user on 21.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Clip+Extensions.h"
#import "Action+Extensions.h"
#import "User+Extensions.h"
#import "VstratorExtensions.h"
#import "Media+Extensions.h"
#import "NSError+Extensions.h"
#import "VstratorStrings.h"
#import "UploadRequest+Extensions.h"

#import <AVFoundation/AVFoundation.h>

@implementation Clip (Extensions)

#pragma mark URLs

+ (NSURL *)urlWithFileURL:(NSURL *)fileURL identity:(NSString *)identity
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentPaths[0];
    NSString *outputPath = [NSString stringWithFormat:@"%@/%@_QOrig.%@", documentPath, identity, fileURL.path.pathExtension];
    return [NSURL fileURLWithPath:outputPath];
}

+ (NSString *)pathForPlaybackQualityForIdentity:(NSString *)identity
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentPaths[0];
    NSString *outputPath = [NSString stringWithFormat:@"%@/%@_QLow.mov", documentPath, identity];
    return outputPath;
}

+ (BOOL)existsPlaybackQualityForIdentity:(NSString *)identity
{
    return [NSFileManager.defaultManager fileExistsAtPath:[self.class pathForPlaybackQualityForIdentity:identity] isDirectory:NO];
}

- (NSString *)pathForPlaybackQuality
{
    return [self.class pathForPlaybackQualityForIdentity:self.identity];
}

- (BOOL)existsPlaybackQuality
{
    return [self.class existsPlaybackQualityForIdentity:self.identity];
}

#pragma mark Lifecycle

- (void)didSave
{
    if (self.isDeleted) {
        if (self.pathForPlaybackQuality) {
            if ([NSFileManager.defaultManager fileExistsAtPath:self.pathForPlaybackQuality])
                [NSFileManager.defaultManager removeItemAtPath:self.pathForPlaybackQuality error:nil];
        }
        if (self.playbackImagesFolder) {
            if ([NSFileManager.defaultManager fileExistsAtPath:self.playbackImagesFolder])
                [NSFileManager.defaultManager removeItemAtPath:self.playbackImagesFolder error:nil];
        }
        if (self.url) {
            NSURL *url = [NSURL URLWithString:self.url];
            if ([NSFileManager.defaultManager fileExistsAtPath:url.path])
                [NSFileManager.defaultManager removeItemAtPath:url.path error:nil];
        }
    }
    [super didSave];
}

#pragma mark Helpers

+ (Clip *)findClipWithIdentity:(NSString *)identity inContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    // checks
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // prepare
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Clip"];
	request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
    // query
	NSArray *matches = [context executeFetchRequest:request error:error];
    if (*error) {
        *error = [NSError errorWithError:*error text:VstratorStrings.ErrorDatabaseSelectText];
    }
    return (*error || matches == nil || matches.count <= 0) ? nil : matches.lastObject;
}

- (void)setupURL:(NSURL *)url title:(NSString *)title authorIdentity:(NSString *)authorIdentity sportName:(NSString *)sportName actionName:(NSString *)actionName note:(NSString *)note callback:(ErrorCallback)callback
{
    [super setupURL:url title:title authorIdentity:authorIdentity sportName:sportName actionName:actionName note:note callback:^(NSError *error) {
        if (error) {
            callback(error);
        } else {
            AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
            AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
            if (track) {
                self.frameRate = @(track.nominalFrameRate);
            } else {
                callback([NSError errorWithText:[NSString stringWithFormat:@"Can't find track for %@", url ]]);
                return;
            }
            callback(nil);
        }
    }];
}

@end

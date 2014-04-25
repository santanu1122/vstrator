//
//  Media+Extensions.m
//  VstratorApp
//
//  Created by user on 29.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "Action+Extensions.h"
#import "Media+Extensions.h"
#import "Clip+Extensions.h"
#import "Session+Extensions.h"
#import "Models+Extensions.h"
#import "NSError+Extensions.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@implementation Media (Extensions)

#pragma mark Properties

-(NSString*)playbackImagesFolder
{
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[cachePathArray lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"PlaybackImages/%@", self.identity]];
}

- (NSString *)sportAndActionTitle
{
    return [NSString stringWithFormat:@"%@, %@", self.action.sport.name, self.action.name];
}

-(BOOL)alreadyUploaded
{
    return self.uploadRequest && self.videoKey && self.uploadRequest.status.intValue == UploadRequestStatusCompleeted;
}

- (BOOL)alreadyUploadedAndProcessed
{
    return self.alreadyUploaded && self.publicURL.length != 0;
}

-(BOOL)isInUploadQueue
{
    return self.uploadRequest && self.uploadRequest.status.intValue != UploadRequestStatusCompleeted;
}

- (BOOL)isInUploadQueueOrNotProcessed
{
    return self.uploadRequest && (self.uploadRequest.status.intValue == UploadRequestStatusUploading ||
                                  self.uploadRequest.status.intValue == UploadRequestStatusProcessing ||
                                  self.uploadRequest.status.intValue == UploadRequestStatusAwaitingOriginalClipProcessing ||
                                  self.uploadRequest.status.intValue == UploadRequestStatusNotStarted);
}

- (BOOL)isUploadedWithErrors
{
    return self.uploadRequest && (self.uploadRequest.status.intValue == UploadRequestStatusUploadedWithError ||
                                  self.uploadRequest.status.intValue == UploadRequestStatusProcessedWithError);
}

#pragma mark ValidateDelete

-(BOOL)validateDelete:(NSError **)error
{
    __block BOOL valid = YES;
    int status = self.uploadRequest.status.intValue;
    if (valid && self.uploadRequest && (status == UploadRequestStatusUploading || status == UploadRequestStatusProcessing)) {
        valid = NO;
        if (error) *error = [self makeValidationErrorWithText:[VstratorStrings ErrorValidateDeleteProcessingMedia]];
    } else if (valid) {
        if (self.exercises.count > 0) {
            valid = NO;
            if (error) *error = [self makeValidationErrorWithText:[VstratorStrings ErrorValidateDeleteMediaWithExcercises]];
        } else [self performBlockIfClip:^(Clip *clip) {
            if (clip.session.count > 0 || clip.sideBySide.count > 0) {
                valid = NO;
                if (error) *error = [self makeValidationErrorWithText:[VstratorStrings ErrorValidateDeleteMediaWithSessions]];
            }
        }];
    }
    return valid;
}

-(NSError*)makeValidationErrorWithText:(NSString*)text
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedFailureReasonErrorKey] = text;
    userInfo[NSValidationObjectErrorKey] = self;
    return [NSError errorWithDomain:@"com.vstrator.Media.validateDelete"
                               code:NSManagedObjectValidationError
                           userInfo:userInfo];
}

#pragma mark Access

- (BOOL)authorIdentityIsPro:(NSString *)authorIdentity
{
    return self.isProMedia;
}

- (BOOL)authorIdentityIsOwner:(NSString *)authorIdentity
{
    return self.author == nil || [self.author.identity isEqualToString:authorIdentity];
}

- (BOOL)isProMedia
{
    return self.author != nil && [self.author.identity isEqualToString:VstratorConstants.ProUserIdentity];
}

- (BOOL)canDelete:(NSString *)authorIdentity
{
    return [self authorIdentityIsOwner:authorIdentity];
}

- (BOOL)canEdit:(NSString *)authorIdentity
{
    return self.type.intValue == MediaTypeUsual && ([self authorIdentityIsOwner:authorIdentity] || [self authorIdentityIsPro:authorIdentity]);
}

- (BOOL)canShare:(NSString *)authorIdentity
{
    return [self canUpload:authorIdentity] && [self isKindOfClass:Session.class];
}

- (BOOL)canUpload:(NSString *)authorIdentity
{
    return self.type.intValue == MediaTypeUsual && [self authorIdentityIsOwner:authorIdentity];
}

- (BOOL)canVstrate:(NSString *)authorIdentity
{
    return [self canEdit:authorIdentity] && [self isKindOfClass:Clip.class];
}

#pragma mark Perform action by media type

-(void)performBlockIfClip:(ClipBlock)block
{
	if ([self isKindOfClass:Clip.class]) block((Clip*) self);
}

-(void)performBlockIfClip:(ClipBlock)clipBlock orSession:(SessionBlock)sessionBlock
{
	if ([self isKindOfClass:Clip.class]) clipBlock((Clip*) self);
	else if ([self isKindOfClass:Session.class]) sessionBlock((Session*) self);
}

-(void)performBlockIfSession:(SessionBlock)block
{
	if ([self isKindOfClass:Session.class]) block((Session*) self);
}

#pragma mark Creator(s)

-(void)setupURL:(NSURL *)url title:(NSString *)title authorIdentity:(NSString *)authorIdentity sportName:(NSString *)sportName actionName:(NSString *)actionName note:(NSString *)note callback:(ErrorCallback)callback
{
	NSError* error = nil;
	self.url = url.absoluteString;
    self.title = title;
    self.note = note;
    self.identity = [[NSProcessInfo processInfo] globallyUniqueString];
	self.date = [NSDate date];
    self.author = [User findUserWithIdentity:authorIdentity inContext:self.managedObjectContext error:&error];
    if (error) {
        if (callback) callback(error);
		return;
	}
    self.action = [Action actionWithName:actionName sportName:sportName inContext:self.managedObjectContext error:&error];
    if (error) {
        if (callback) callback(error);
		return;
	}
	[self.class processMediaWithURL:url callback:^(NSError *error1, NSData *thumbnail, NSNumber *duration, NSString *urlString, CGSize size) {
        if (!error) {
            self.thumbnail = thumbnail;
            self.duration = duration;
            self.url = urlString;
            self.width = [NSNumber numberWithInt:size.width];
            self.height = [NSNumber numberWithInt:size.height];
        }
        if (callback) callback(error1);
    }];
}

#pragma mark Find

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContextWithOptions(newSize, 1.0f, 0.0f);
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

+ (void)processMediaWithURL:(NSURL*)url callback:(ProcessMediaCallback)callback
{
    // check
    NSAssert(url && callback, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];

    imageGenerator.appliesPreferredTrackTransform = YES;

    Float64 durationSeconds = CMTimeGetSeconds(asset.duration);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);

    //    dispatch_queue_t callingQueue = dispatch_get_current_queue();
    //    dispatch_queue_t queue = dispatch_queue_create("Process media URL queue", 0);
    //    dispatch_async(queue, ^{
    NSError *error = nil;
    CMTime actualTime;
    NSData *newThumbnail = nil;
    CGSize newThumbnailSize = CGSizeZero;
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    if (halfWayImage != nil) {
        UIImage *thumbnail = [UIImage imageWithCGImage:halfWayImage];
        newThumbnailSize = thumbnail.size;
        CGFloat minSize = MIN(thumbnail.size.height, thumbnail.size.width);
        if (minSize > 0) {
            double scale = (double) VstratorConstants.ThumbnailSize / minSize;
            CGSize size = CGSizeMake(thumbnail.size.width * scale, thumbnail.size.height * scale);
            newThumbnail = UIImageJPEGRepresentation([Clip imageWithImage:thumbnail scaledToSize:size], VstratorConstants.ThumbnailJPEGQuality);
        } else {
            newThumbnail = UIImageJPEGRepresentation(thumbnail, VstratorConstants.ThumbnailJPEGQuality);
        }
        CGImageRelease(halfWayImage);
    }

    NSNumber *newDuration = @(durationSeconds);
    NSString *newUrl = url.absoluteString;

    CGSize newSize = newThumbnailSize;
    if (CGSizeEqualToSize(newSize, CGSizeZero)) {
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if (tracks.count > 0) {
            AVAssetTrack *track = [tracks objectAtIndex:0];
            newSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
        } else {
            NSLog(@"Can't find track for %@", url);
        }
    }
    //        dispatch_async(callingQueue, ^{
    callback(nil, newThumbnail, newDuration, newUrl, newSize);
    //        });
    //    });
    //    dispatch_release(queue);
}

+(id)findMediaWithURL:(NSURL *)url mediaType:(SearchMediaType)mediaType authorIdentity:(NSString *)authorIdentity inContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    // checks
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // prepare
    NSArray *requestConditions = @[[NSPredicate predicateWithFormat:@"url = %@", url.absoluteString], [NSPredicate predicateWithFormat:@"author.identity = %@", authorIdentity]];
	NSString* entityName = nil;
	switch (mediaType) {
		case SearchMediaTypeClips:
			entityName = @"Clip";
			break;
		case SearchMediaTypeSessions:
			entityName = @"Session";
			break;
		case SearchMediaTypeAll:
		default:
			entityName = @"Media";
			break;
	}
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
	request.predicate = [NSPredicate predicateWithFormat:[requestConditions componentsJoinedByString:@" AND "]];
    // query
	NSArray *matches = [context executeFetchRequest:request error:error];
    if (*error) {
        *error = [NSError errorWithError:*error text:VstratorStrings.ErrorDatabaseSelectText];
    }
    return (*error || matches == nil || matches.count <= 0) ? nil : matches.lastObject;
}

+(Media*)mediaFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    BOOL isSession = [object[@"videoKeyType"] boolValue];
    Media* media = [NSEntityDescription insertNewObjectForEntityForName:isSession ? @"Session" : @"Clip" inManagedObjectContext:context];
    media.identity = [[NSProcessInfo processInfo] globallyUniqueString];
    media.title = object[@"title"];
    media.note = object[@"notes"];
    media.thumbURL = object[@"thumbUrl"];
    // date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];//ZZZ"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    media.date = [dateFormatter dateFromString:object[@"videoDate"]];
    if (!media.date) media.date = [NSDate date];
    media.publicURL = object[@"videoUrl"];
    media.videoKey = object[@"videoKey"];
    media.action = [Action actionWithName:object[@"action"] sportName:object[@"sport"] inContext:context error:error];
    if (!*error) {
        NSString* authorID = object[@"authorID"];
        if (!authorID || [authorID caseInsensitiveCompare:[VstratorConstants ApplicationId]] == NSOrderedSame) {
            media.author = [User findUserWithIdentity:[VstratorConstants ProUserIdentity] inContext:context error:error];
        } else {
            media.author = [User findUserWithVstratorIdentity:authorID inContext:context error:error];
        }
    }
    return media;
}

@end

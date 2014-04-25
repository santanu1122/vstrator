//
//  UploadRequest+Extensions.m
//  VstratorApp
//
//  Created by Mac on 01.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "UploadRequest+Extensions.h"
#import "UploadFile+Extensions.h"
#import "Callbacks.h"
#import "Media+Extensions.h"
#import "Session+Extensions.h"
#import "Clip+Extensions.h"
#import "AccountController2.h"

const int MaxUploadAttempts = 3;
const int MaxRetrieveURLAttempts = 20;

@implementation UploadRequest (Extensions)

+(int)nextSortOrderInContext:(NSManagedObjectContext*)context
{
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"UploadRequest"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:NO]];
    request.fetchLimit = 1;
    NSError* error = nil;
    NSArray* result = [context executeFetchRequest:request error:&error];
    if (!error) {
        UploadRequest* uploadRequest = [result lastObject];
        return uploadRequest ? uploadRequest.sortOrder.intValue + 1 : 0;
    }
    return 0;
}

+(UploadRequest*)addMedia:(Media *)media withVisibility:(UploadRequestVisibility)visibility error:(NSError**)error
{
    NSParameterAssert(error);
    NSAssert(media, @"Argument media is nil");
    if (media.uploadRequest || media.videoKey) {
        NSDictionary* details = @{NSLocalizedDescriptionKey: @"The media was already uploaded"};
        *error = [NSError errorWithDomain:@"com.vstrator.UploadRequest.addMedia.error" code:-1 userInfo:details];
        return nil;
    }

    UploadRequest *uploadRequest = [NSEntityDescription insertNewObjectForEntityForName:@"UploadRequest" inManagedObjectContext:media.managedObjectContext];

    uploadRequest.identity = [[NSProcessInfo processInfo] globallyUniqueString];
	uploadRequest.media = media;
    uploadRequest.visibility = [NSNumber numberWithInt:visibility];
    
	[media performBlockIfClip:^(Clip *clip) {
        NSURL* url;
        if (AccountController2.sharedInstance.userAccount.uploadQuality == UploadQualityLow && clip.existsPlaybackQuality) {
            url = [NSURL fileURLWithPath:clip.pathForPlaybackQuality];
        } else {
            url = [NSURL URLWithString:clip.url];
        }
        [UploadFile createUploadFileForRequest:uploadRequest type:UploadFileTypeVideo urlString:url.absoluteString];
    } orSession:^(Session *session) {
        if (!session.originalClip) {
            // Imported session, upload just video
            [UploadFile createUploadFileForRequest:uploadRequest type:UploadFileTypeVideo urlString:media.url];
            return;
        }
        if (!session.originalClip.videoKey) {
            uploadRequest.status = @(UploadRequestStatusAwaitingOriginalClipProcessing);
            if (!session.originalClip.uploadRequest) {
                // Add the separate request for the originalClip upload
                [self addMedia:session.originalClip withVisibility:visibility error:error];
                if (*error) return;
            }
        }
        if (session.isSideBySide && !session.originalClip2.videoKey) {
            uploadRequest.status = @(UploadRequestStatusAwaitingOriginalClipProcessing);
            if (!session.originalClip2.uploadRequest) {
                // Add the separate request for the originalClip2 upload
                [self addMedia:session.originalClip2 withVisibility:visibility error:error];
                if (*error) return;
            }
        }
		[UploadFile createUploadFileForRequest:uploadRequest type:UploadFileTypeAudio urlString:session.audioFileURL.absoluteString];
		[UploadFile createUploadFileForRequest:uploadRequest type:UploadFileTypeTelestration urlString:nil];
	}];

	uploadRequest.requestDate = [NSDate date];
    uploadRequest.sortOrder = @([UploadRequest nextSortOrderInContext:media.managedObjectContext]);
    
    return uploadRequest;
}

-(int)moveEarlier:(int)positions error:(NSError**)error
{
    return [self move:positions error:error];
}

-(int)moveLater:(int)positions error:(NSError**)error
{
    return [self move:-positions error:error];
}

-(int)move:(int)positions error:(NSError**)error
{
    NSAssert(positions, @"Argument error. positions == 0");
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"UploadRequest"];
    if (positions > 0) {
        request.predicate = [NSPredicate predicateWithFormat:@"sortOrder < %@", self.sortOrder];
        request.fetchLimit = positions;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:NO]];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"sortOrder > %@", self.sortOrder];
        request.fetchLimit = -positions;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]];
    }
    NSArray* result = [self.managedObjectContext executeFetchRequest:request error:error];
    if (*error) return 0;
    for (int i = 0; i < result.count; ++i) {
        UploadRequest* other = result[i];
        NSNumber* temp = other.sortOrder;
        other.sortOrder = self.sortOrder;
        self.sortOrder = temp;
    }
    return result.count;
}

-(void)retry
{
    [self.media performBlockIfSession:^(Session *session) {
        if (session.originalClip.uploadRequest)
            [session.originalClip.uploadRequest retry];
        if (session.isSideBySide && session.originalClip2.uploadRequest)
            [session.originalClip2.uploadRequest retry];
    }];
    switch (self.status.intValue) {
        case UploadRequestStatusUploadedWithError:
            self.status = @(UploadRequestStatusUploading);
            break;
        case UploadRequestStatusProcessedWithError:
            self.status = @(UploadRequestStatusProcessing);
            break;
        case UploadRequestStatusStopped:
            self.status = @(UploadRequestStatusNotStarted);
            break;
        default:
            return;
    }
    [self updateStatus];
    self.failedAttempts = @0;
}

-(void)stop
{
    self.status = @(UploadRequestStatusStopped);
}

-(void)updateDependantRequests
{
    [self.media performBlockIfClip:^(Clip *clip) {
        for (Session* dependant in clip.session) {
            if (dependant.uploadRequest) {
                [dependant.uploadRequest updateStatus];
            }
        }
        for (Session* dependant in clip.sideBySide) {
            if (dependant.uploadRequest) {
                [dependant.uploadRequest updateStatus];
            }
        }
    }];
}

-(void)updateStatus
{
    NSSet* inQueueStatuses = [NSSet setWithArray:@[
                              @(UploadRequestStatusAwaitingOriginalClipProcessing),
                              @(UploadRequestStatusNotStarted)]];
    NSSet* errorStatuses = [NSSet setWithArray:@[
                            @(UploadRequestStatusProcessedWithError),
                            @(UploadRequestStatusUploadedWithError)]];

    if (![inQueueStatuses containsObject:self.status] && ![errorStatuses containsObject:self.status]) return;
    
    [self.media performBlockIfSession:^(Session *session) {
        if (session.originalClip.uploadRequest && [errorStatuses containsObject:session.originalClip.uploadRequest.status]) {
            self.status = session.originalClip.uploadRequest.status;
        } else if (session.isSideBySide && session.originalClip2.uploadRequest && [errorStatuses containsObject:session.originalClip2.uploadRequest.status]) {
            self.status = session.originalClip2.uploadRequest.status;
        } else if (!session.originalClip.videoKey || (session.isSideBySide && !session.originalClip2.videoKey)) {
            self.status = @(UploadRequestStatusAwaitingOriginalClipProcessing);
        } else {
            self.status = @(UploadRequestStatusNotStarted);
        }
    }];
}

@end

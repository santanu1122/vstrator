//
//  UploadRequest+Extensions.h
//  VstratorApp
//
//  Created by Mac on 01.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadRequest.h"

@class Media;

extern const int MaxUploadAttempts;
extern const int MaxRetrieveURLAttempts;

typedef enum {
	UploadRequestStatusNotStarted = 0,
    UploadRequestStatusAwaitingOriginalClipProcessing = 1,
    UploadRequestStatusUploading = 2,
	UploadRequestStatusUploadedWithError = 3,
    UploadRequestStatusProcessing = 4,
    UploadRequestStatusProcessedWithError = 5,
	UploadRequestStatusCompleeted = 6,
    UploadRequestStatusStopped = 7,
    // The last two used only in the requests to mediaService
    UploadRequestStatusInProgress, // Fetch Uploading or Processing requests
    UploadRequestStatusAll // Fetch all requests
} UploadRequestStatus;

typedef enum {
    UploadRequestVisibilityPrivate, // The content is private to the user
    UploadRequestVisibilityLocal,   // The content can be shared with individuals that are connected with the user on the website and
                                    // cannot be shared externally to non Vstrator.com authenticated users (Can not be shared or viewed in public playback)
    UploadRequestVisibilityPublic,  // The content may be shared and can be played in public viewers
} UploadRequestVisibility;

@interface UploadRequest (Extensions)

+(UploadRequest*)addMedia:(Media *)media withVisibility:(UploadRequestVisibility)visibility error:(NSError**)error;
-(int)moveEarlier:(int)positions error:(NSError**)error;
-(int)moveLater:(int)positions error:(NSError**)error;
-(void)retry; // Clear failedAttempts count
-(void)stop;
-(void)updateDependantRequests;
-(void)updateStatus;

@end

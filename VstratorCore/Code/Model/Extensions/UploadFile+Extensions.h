//
//  UploadFile+Extensions.h
//  VstratorApp
//
//  Created by user on 21.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "UploadFile.h"

@class UploadRequest;

typedef enum {
	UploadFileTypeVideo = 0,
	UploadFileTypeAudio = 1,
	UploadFileTypeTelestration = 2,
} UploadFileType;

typedef enum {
	UploadFileStatusNotStarted = 0,
	UploadFileStatusUploaded = 1,
	UploadFileStatusFinishedWithError = 2,
} UploadFileStatus;

@interface UploadFile (Extensions)

+(UploadFile *)createUploadFileForRequest:(UploadRequest *)uploadRequest type:(UploadFileType)type urlString:(NSString*)url;

@end

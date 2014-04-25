//
//  UploadFile+Extensions.m
//  VstratorApp
//
//  Created by user on 21.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "UploadFile+Extensions.h"
#import "UploadRequest.h"

@implementation UploadFile (Extensions)

+(UploadFile *)createUploadFileForRequest:(UploadRequest *)uploadRequest type:(UploadFileType)type urlString:(NSString*)url
{
    UploadFile *file = [NSEntityDescription insertNewObjectForEntityForName:@"UploadFile" inManagedObjectContext:uploadRequest.managedObjectContext];
    file.identity = [[NSProcessInfo processInfo] globallyUniqueString];
	file.request = uploadRequest;
	file.type = [NSNumber numberWithInt:type];
	file.status = @(UploadFileStatusNotStarted);
	file.url = url;
	return file;
}

@end

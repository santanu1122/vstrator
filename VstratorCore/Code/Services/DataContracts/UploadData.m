//
//  UploadData.m
//  VstratorApp
//
//  Created by user on 16.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "UploadData.h"

#import <MobileCoreServices/UTType.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <CoreLocation/CoreLocation.h>

@implementation UploadData

@synthesize identity = _identity;
@synthesize name = _name;
@synthesize mimeType = _mimeType;
@synthesize content = _content;
@synthesize url = _url;
@synthesize type = _type;

-(BOOL)prepareWithRecordingKey:(NSString*)recordingKey error:(NSError**)error
{
    switch (self.type) {
        case UploadFileTypeVideo:
            self.name = [recordingKey stringByAppendingString:@".raw"];
            self.content = [self videoContentByURL:self.url error:error];
            self.mimeType = [self mimeTypeByFilePath:self.url.path];
            break;
        case UploadFileTypeAudio:
            self.name = [recordingKey stringByAppendingString:@"audio.wav"];
            self.content = [NSData dataWithContentsOfURL:self.url];
            self.mimeType = [self mimeTypeByFilePath:self.url.path];
            break;
        case UploadFileTypeTelestration:
            self.name = [recordingKey stringByAppendingString:@"markup.dat"];
            self.mimeType = @"application/json";
            //self.content already loaded here
            break;
    }
    if (!self.mimeType)
        self.mimeType = @"application/octet-stream";
    return !*error;
}

-(NSData*)videoContentByURL:(NSURL*)url error:(NSError**)error
{
    NSParameterAssert(error);
    if (![[NSScanner scannerWithString:url.absoluteString] scanString:@"assets-library://" intoString:nil])
        return [NSData dataWithContentsOfURL:url];

    if (![CLLocationManager locationServicesEnabled]
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSDictionary* dict = @{NSLocalizedDescriptionKey: @"Location services disabled"};
        *error = [NSError errorWithDomain:@"com.vstrator.videoContentByURL" code:-1 userInfo:dict];
        return nil;
    }

    // Synchronize assets library access
    __block NSData* data = nil;
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:url resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc((size_t)rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0. length:(size_t)rep.size error:error];
        if (!*error) data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        dispatch_semaphore_signal(ds);
    } failureBlock:^(NSError *e) {
        *error = e;
        dispatch_semaphore_signal(ds);
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    dispatch_release(ds);
    return data;
}

-(NSString*)mimeTypeByFilePath:(NSString *)path
{
	// Get the UTI from the file's extension:
	CFStringRef pathExtension = (__bridge_retained CFStringRef)[path pathExtension];
	CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
	CFRelease(pathExtension);
	
	// The UTI can be converted to a mime type:
	NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
	if (type) CFRelease(type);
    
	return mimeType;
}

@end

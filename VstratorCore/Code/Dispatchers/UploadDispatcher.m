//
//  UploadDispatcher.m
//  VstratorApp
//
//  Created by user on 15.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "UploadDispatcher.h"
#import "VstratorAppServices.h"

#import "AccountController2.h"
#import "BackgroundTaskWrapper.h"
#import "Clip+Extensions.h"
#import "ClipMetaInfo.h"
#import "Media+Extensions.h"
#import "MediaService.h"
#import "NSFileManager+Extensions.h"
#import "ServiceFactory.h"
#import "ServiceFactory.h"
#import "UploadData.h"
#import "UploadRequestInfo.h"
#import "VideoStatusInfo.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Reachability.h>

#ifdef DEBUG
//#define kVAUploadDispatcherDebug
#endif

static const NSTimeInterval SleepInterval = 10.;

static UploadDispatcher* SharedInstance;

@interface UploadDispatcher()

@property (atomic) BOOL needToStop;
@property (atomic) BOOL uploadIsRunning;
@property (atomic) BOOL urlRetrievingIsRunning;

@property (nonatomic, strong, readonly) MediaService *mediaService;
@property (nonatomic, strong, readonly) id<UploadService> uploadService;
@property (nonatomic, strong, readonly) Reachability* reachability;

@end

@implementation UploadDispatcher

@synthesize needToStop = _needToStop;
@synthesize uploadService = _uploadService;
@synthesize mediaService = _mediaService;
@synthesize reachability = _reachability;

-(id<UploadService>)uploadService
{
	return _uploadService ? _uploadService : (_uploadService = [[ServiceFactory sharedInstance] createUploadService]);
}

-(MediaService *)mediaService
{
	return _mediaService ? _mediaService : (_mediaService = [MediaService new]);
}

-(Reachability*)reachability
{
    if (!_reachability) {
        _reachability = [Reachability reachabilityForInternetConnection];
        _reachability.reachableOnWWAN = AccountController2.sharedInstance.userAccount.uploadOptions == UploadOnWWAN;
        __block __weak UploadDispatcher* this = self;
        _reachability.reachableBlock = ^(Reachability* dontUsed) {
            dispatch_queue_t queue = dispatch_queue_create(NULL, 0);
            dispatch_async(queue, ^{
                NSLog(@"Starting upload queue...");
                this.needToStop = NO;
                [this updateRequestsStatuses];
                [this processUploadRequestsAsync];
                [this retrievePublicURLsAsync];
            });
            dispatch_release(queue);
        };
        _reachability.unreachableBlock = ^(Reachability* dontUsed) {
            NSLog(@"Internet connection lost. Stopping upload queue...");
            this.needToStop = YES;
        };
    }
    return _reachability;
}

-(id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uploadOptionsChanged:)
                                                     name:VAUploadOptionsChangedNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VAUploadOptionsChangedNotification
                                                  object:nil];
}

-(void)uploadOptionsChanged:(NSNotification*)notification
{
    NSLog(@"Upload options changed");
    [self.reachability stopNotifier];
    self.reachability.reachableOnWWAN = AccountController2.sharedInstance.userAccount.uploadOptions == UploadOnWWAN;
    @synchronized(self) {
        if (!self.uploadIsRunning && !self.urlRetrievingIsRunning) return;
    }
    [self.reachability startNotifier];
    if (!self.reachability.isReachable)
        self.reachability.unreachableBlock(self.reachability);
}

#pragma mark - Interface

+(UploadDispatcher *)sharedInstance
{
	return SharedInstance ? SharedInstance : (SharedInstance = [UploadDispatcher new]);
}

-(void)stop
{
#ifdef kVAUploadDispatcherActive
    [self.reachability stopNotifier];
	self.needToStop = YES;
#endif
}

-(void)start
{
#ifdef kVAUploadDispatcherActive
    [self.reachability startNotifier];
    if (!self.reachability.isReachable)
        NSLog(@"Warning! Internet connection unreachable");
    else
        self.reachability.reachableBlock(self.reachability);
#endif
}

-(void)resume
{
#ifdef kVAUploadDispatcherActive
    [self start];
#endif
}

#pragma mark - Internal

-(void)processUploadRequestsAsync
{
    @synchronized(self) {
        if (self.uploadIsRunning) return;
        self.uploadIsRunning = YES;
    }
    [[BackgroundTaskWrapper wrapperWithTask:^{
        NSLog(@"Upload queue started");
		while (!self.needToStop) {
            if (![self processUploadRequest]) break;
        }
        @synchronized(self) {
            self.uploadIsRunning = NO;
        }
        NSLog(@"Upload queue stopped");
    }] run];
}

-(void)updateRequestsStatuses
{
    NSAssert(dispatch_get_current_queue() != dispatch_get_main_queue(), @"updateRequestsStatuses: The method called in a wrong queue");
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    [self.mediaService fetchNotFinishedRequests:^(NSArray* requests, NSError* error) {
        for (UploadRequest* request in requests) {
            [request updateStatus];
        }
        [self.mediaService saveChanges:^(NSError *savingError) {
            if (error) {
                NSLog(@"Cannot save upload request statuses. Error: %@", savingError);
            }
            dispatch_semaphore_signal(ds);
        }];
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    dispatch_release(ds);
}

-(BOOL)processUploadRequest
{
    __block BOOL uploadStarted = NO;
    
    // Process only one request at a time
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    
    // Fetch upload request from database
    NSArray *authorIdentities = @[ VstratorConstants.ProUserIdentity, AccountController2.sharedInstance.userIdentity ];
    [self.mediaService nextUploadRequestInfo:authorIdentities callback:^(UploadRequest* uploadRequest, UploadRequestInfo *info, NSError *error0) {
        if (error0 || !info) {
            if (error0) NSLog(@"Cannot get next upload request info. Error: %@", error0);
            if (info) {
                uploadStarted = YES; // This is in order to pop up the error upload request and not to stop the upload queue
                [self.mediaService uploadRequestCompleeted:info.identity
                                                  videoKey:nil
                                                 withError:error0
                                                  callback:^(NSError *error) {
                                                      if (error) NSLog(@"Cannot change status of error upload request. Error: %@", error);
                                                  }];
            }
            dispatch_semaphore_signal(ds);
            return;
        }

        NSLog(@"Processing a new upload request");

        NSLog(@"Media URL: %@", uploadRequest.media.url);
        NSURL *fixedUrl = [self fixUpVideoUrl:uploadRequest];
        for (UploadData *data in info.data) {
            if (data.type != UploadFileTypeVideo) continue;
            data.url = fixedUrl;
        }
        
        [self ensureUploadRequestInfoHasCorrectData:info callback:^(NSError *requestError) {
            if (requestError) {
                NSLog(@"Cannot fetch upload request data or save it to database. Error: %@", requestError);
                dispatch_semaphore_signal(ds);
                return;
            }
            
            uploadStarted = YES;
            
            [self.mediaService changeUploadRequest:info.identity status:UploadRequestStatusUploading];
            [self processUploadInfoAsync:info callback:^(NSError* uploadError) {
                if (uploadError) {
                    NSLog(@"Upload request failed. Error: %@", uploadError);
                    [self.mediaService uploadRequestCompleeted:info.identity
                                                      videoKey:nil
                                                     withError:uploadError
                                                      callback:^(NSError *error)
                     {
                         if (error) NSLog(@"Cannot change the status of uploaded with an error request. Error: %@", error);
                         dispatch_semaphore_signal(ds);
                     }];
                    return;
                }
                NSLog(@"Upload request done");
                
                [self.mediaService clipMetaInfoForUploadRequestIdentity:info.identity callback:^(ClipMetaInfo *metaInfo, NSError *getMetaInfoError) {
                    if (getMetaInfoError || !metaInfo) {
                        if (getMetaInfoError) {
                            NSLog(@"Getting clip metainfo failed. Error: %@", getMetaInfoError);
                        } else {
                            // The media already has a videoKey, so we only have to change their status to "processing"
                            [self.mediaService changeUploadRequest:info.identity status:UploadRequestStatusProcessing];
                        }
                        dispatch_semaphore_signal(ds);
                        return;
                    }
                    metaInfo.recordingKey = info.recordingKey;
                    metaInfo.userKey = AccountController2.sharedInstance.userAccount.vstratorIdentity;
                    metaInfo.activityDate = [NSDate date];
                    
                    //if (info.isVstration && !metaInfo.framesKey) metaInfo.framesKey = info.recordingKey;
                    
                    [self.uploadService processClipMetaInfo:metaInfo isVstration:info.isVstration callback:^(VideoStatusInfo *videoStatusInfo, NSError *processMetaInfoError) {
                        if (processMetaInfoError) {
                            NSLog(@"Processing clip metainfo failed. Error: %@", processMetaInfoError);
                        }
                        [self.mediaService uploadRequestCompleeted:info.identity
                                                          videoKey:videoStatusInfo.videoKey
                                                         withError:processMetaInfoError
                                                          callback:^(NSError *error) {
                                                              if (error) NSLog(@"Cannot change status of uploaded request. Error: %@", error);
                                                              dispatch_semaphore_signal(ds);
                                                          }];
                    }];
                }];
            }];
        }];
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    dispatch_release(ds);
    return uploadStarted;
}

-(NSURL*)fixUpVideoUrl:(UploadRequest*)request
{
    __block NSURL *url = [NSURL URLWithString:request.media.url];
    if (AccountController2.sharedInstance.userAccount.uploadQuality == UploadQualityHigh)
        return url;
    [request.media performBlockIfClip:^(Clip *clip) {
        if ([clip existsPlaybackQuality] ||
            [self createLowQualityVideoForClipIdentity:clip.identity url:[NSURL URLWithString:clip.url]]) {
            url = [[NSURL alloc] initFileURLWithPath:clip.pathForPlaybackQuality];
        }
    }];
    return url;
}

-(BOOL)createLowQualityVideoForClipIdentity:(NSString*)clipIdentity url:(NSURL*)url
{
    __block BOOL result = NO;
    do {
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        
        AVAssetTrack* assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        CGSize assetSize = assetVideoTrack.naturalSize;
        if (assetSize.width <= 640 && assetSize.height <= 640) break;

        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
        if (![compatiblePresets containsObject:AVAssetExportPreset640x480]) break;
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset640x480];
        NSString *outputPath = [Clip pathForPlaybackQualityForIdentity:clipIdentity];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        exportSession.outputURL = [NSURL fileURLWithPath:outputPath];
        
        dispatch_semaphore_t ds = dispatch_semaphore_create(0);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if (exportSession.status != AVAssetExportSessionStatusCompleted) {
                NSLog(@"Media Import: compression error: %@", exportSession.error.localizedDescription);
                if ([NSFileManager.defaultManager fileExistsAtPath:outputPath isDirectory:NO])
                    [NSFileManager.defaultManager removeItemAtPath:outputPath error:nil];
                dispatch_semaphore_signal(ds);
                return;
            }
            NSDictionary *fileAttributes = [NSFileManager.defaultManager attributesOfItemAtPath:outputPath error:nil];
            NSNumber *fileSize = fileAttributes[NSFileSize];
            NSLog(@"Media Import: compressed file size: %ld", fileSize.longValue);
            NSError* error0 = nil;
            [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:outputPath] error:&error0];
            if (error0) {
                NSLog(@"Cannot set skip backup attr for file '%@'", outputPath);
            }
            result = YES;
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
        dispatch_release(ds);
    } while (0);
    return result;
}

-(void)ensureUploadRequestInfoHasCorrectData:(UploadRequestInfo*)info callback:(ErrorCallback)callback
{
    NSParameterAssert(callback);
    if (info.recordingKey) {// && info.uploadURL) {
        callback(nil);
        return;
    }
    // Fetch the additional upload request data from vstrator api
    UploadType type = info.isVstration ? UploadTypeSession : UploadTypeClip;
    [self.uploadService requestForUpload:type callback:^(UploadRequestInfo *loadedInfo, NSError *error) {
        if (error) {
            callback(error);
        } else {
            info.recordingKey = loadedInfo.recordingKey;
            info.uploadURL = loadedInfo.uploadURL;
            [self.mediaService updateUploadRequestWithInfo:info callback:callback];
        }
    }];
}

-(void)processUploadInfoAsync:(UploadRequestInfo*)info callback:(ErrorCallback)callback
{
    dispatch_queue_t queue = dispatch_queue_create("processUploadInfo queue", 0);
    dispatch_async(queue, ^{
        NSError* error = nil;
        for (int i = 0; i < info.data.count && !error; ++i) {
            UploadData* data = (info.data)[i];
            [data prepareWithRecordingKey:info.recordingKey error:&error];
            if (error) {
                NSLog(@"Cannot prepare data '%@' for upload. Error: %@", data.name, error);
                break;
            }
            data.url = info.uploadURL;
            [self uploadData:data error:&error];
            if (error) {
                NSLog(@"Cannot upload data '%@'. Error: %@", data.name, error);
                break;
            }
        }
        callback(error);
    });
    dispatch_release(queue);
}

-(BOOL)uploadData:(UploadData*)data error:(NSError**)error
{
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    NSLog(@"Sending data: '%@' as '%@'", data.name, data.mimeType);
    [self.uploadService uploadData:data withCallback:^(NSError *uploadError) {
        if (uploadError) {
            NSLog(@"Upload data '%@' failed. Error: %@", data.name, uploadError);
            if (error) *error = uploadError;
        } else
            NSLog(@"Upload data '%@' done.", data.name);
        [self.mediaService dataUploaded:data withError:uploadError];
        dispatch_semaphore_signal(ds);
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    dispatch_release(ds);
    return !*error;
}

#pragma mark - Retrieve URLs

-(void)retrievePublicURLsAsync
{
    @synchronized(self) {
        if (self.urlRetrievingIsRunning) return;
        self.urlRetrievingIsRunning = YES;
    }
    
    [[BackgroundTaskWrapper wrapperWithTask:^{
        int sortOrder = -1;
		while (!self.needToStop) {
            sortOrder = [self retrievePublicURLWithSortOrder:sortOrder];
            if (sortOrder == -1 && !self.needToStop) [NSThread sleepForTimeInterval:SleepInterval];
        }
        @synchronized(self) {
            self.urlRetrievingIsRunning = NO;
        }
    }] run];
}

-(int)retrievePublicURLWithSortOrder:(int)sortOrder
{
    __block int nextOrder = -1;
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    NSArray *authorIdentities = @[ VstratorConstants.ProUserIdentity, AccountController2.sharedInstance.userIdentity ];
    [self.mediaService nextCompleetedUploadRequestWithoutURL:authorIdentities
                                                   sortOrder:sortOrder
                                                    callback:^(UploadRequest* uploadRequest, NSError* mediaServiceError)
    {
        if (mediaServiceError) {
            NSLog(@"Cannot get uploadRequest. Error: %@", mediaServiceError);
        } else if (uploadRequest) {
            nextOrder = uploadRequest.sortOrder.intValue;
            [self getURLForUploadRequest:uploadRequest callback:^(NSError* getError) {
                if (getError) NSLog(@"Cannot get public URL for upload request. Error: %@", getError);
                dispatch_semaphore_signal(ds);
            }];
            return;
        }
        dispatch_semaphore_signal(ds);
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    dispatch_release(ds);
    return nextOrder;
}

-(void)getURLForUploadRequest:(UploadRequest*)uploadRequest callback:(ErrorCallback)callback
{
    NSString* identity = uploadRequest.identity;
    NSString* videoKey = uploadRequest.media.videoKey;
    BOOL isVstration = [uploadRequest.media isKindOfClass:[Session class]];
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    [self.uploadService getURLForVideoKey:videoKey isVstration:isVstration callback:^(NSURL* url, NSError* error) {
        if (error || url)
            [self.mediaService uploadRequest:identity gotURL:url withError:error];
        callback(error);
        dispatch_semaphore_signal(ds);
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    dispatch_release(ds);
}

@end

//
//  TelestrationRecordingController.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationRecordingController.h"
#import "TelestrationConstants.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioSession.h>
#import <CoreAudio/CoreAudioTypes.h>

//#define APPLE_LOSSLESS_SOUND

@interface TelestrationRecordingController() <AVAudioRecorderDelegate>

@property (nonatomic, strong) TelestrationRecordingController *selfRef;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSTimer *audioRecorderTimer;

@end


@implementation TelestrationRecordingController

#pragma mark - Properties

@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize fileName = _fileName;
@synthesize currentTime = _currentTime;
@synthesize recording = _recording;

@synthesize selfRef = _selfRef;
@synthesize audioRecorder = _audioRecorder;
@synthesize audioRecorderTimer = _audioRecorderTimer;

- (void)setError:(NSError *)error
{
    _error = error;
}

- (NSTimeInterval)currentTime
{
    @synchronized(self) {
        return _currentTime;
    }
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    BOOL hasChanges = NO;
    @synchronized(self) {
        hasChanges = _currentTime != currentTime;
        _currentTime = currentTime;
    }
    if (hasChanges && [self.delegate respondsToSelector:@selector(telestrationRecordingController:didChangeCurrentTime:)])
        [self.delegate telestrationRecordingController:self didChangeCurrentTime:currentTime];
}

- (BOOL)recording
{
    @synchronized(self) {
        return _recording;
    }
}

- (void)setRecording:(BOOL)recording
{
    BOOL hasChanges = NO;
    @synchronized(self) {
        hasChanges = _recording != recording;
        _recording = recording;
    }
    if (hasChanges && [self.delegate respondsToSelector:@selector(telestrationRecordingController:didChangeRecordingState:)])
        [self.delegate telestrationRecordingController:self didChangeRecordingState:recording];
}

#pragma mark - Ctor

- (NSError *)activateAudioSession
{
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error == nil)
        [audioSession setActive:YES error:&error];
    return error;
}

- (void)deactivateAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (id)initWithDelegate:(id<TelestrationRecordingControllerDelegate>)delegate fileName:(NSString *)fileName error:(NSError **)error
{
    self = [super init];
    if (self) {
        NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
        *error = nil;
        // audio session
        *error = [self activateAudioSession];
        if (*error == nil) {
            // paths
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            _fileName = [NSString stringWithFormat:@"%@.caf", [self.class newFileNameWithSourceFileName:fileName editMode:NO]];
            NSURL *finalURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", path, self.fileName]];
            // settings
#ifdef APPLE_LOSSLESS_SOUND
            NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithFloat: 44100.0], AVSampleRateKey, 
                                            [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey, 
                                            [NSNumber numberWithInt: 1], AVNumberOfChannelsKey, 
                                            [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey, 
                                            nil];
#else
            NSDictionary *recordSettings = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
                                            AVSampleRateKey: [NSNumber numberWithInt:44100.0],
                                            AVNumberOfChannelsKey: @1,
                                            AVLinearPCMBitDepthKey: @16,
                                            AVLinearPCMIsBigEndianKey: @NO,
                                            AVLinearPCMIsFloatKey: @NO};
#endif
            self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:finalURL settings:recordSettings error:error];
            if (*error == nil) {
                if ([self.audioRecorder prepareToRecord]) {
                    self.delegate = delegate;
                } else {
                    *error = [NSError errorWithText:VstratorStrings.ErrorAudioRecorderInitText];
                }
            }
        }
        self.error = *error;
    }
    return self;
}

- (void)dealloc
{
    [self stopRecording];
}

#pragma mark - TelestrationFileController replacements

+ (int)newFileNameHighestIndexWithPrefix:(NSString *)prefix
{
    int highest = 0;
    if(prefix == nil)
        return highest;
    
    NSError *error = nil;
    NSArray *p = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = p[0];
    NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:&error];
    for (NSString *filePath in files) {
        if ([filePath rangeOfString:prefix].location != NSNotFound) {
            NSLog(@"Found %@: %@", prefix, filePath);
            highest++;
        }
    }
    NSLog(@"Found %d files", highest);
    return (highest + highest % 2) / 2;
}

+ (NSString *)newFileNameWithSourceFileName:(NSString *)fileName editMode:(BOOL)editMode;
{
    // from whatever down to 12323546-1
    NSString *finalFile = nil;
    NSString *fileBase = [fileName.lastPathComponent stringByDeletingPathExtension];
    if ([NSString isNilOrEmpty:fileBase])
        fileBase = @"temp";
    // get the -1 if it exists so we know the index.
    int number = [self.class newFileNameHighestIndexWithPrefix:fileName];
    if (number <= 0 || editMode) {
        finalFile = [NSString stringWithFormat:@"%@", fileBase];
    } else {
        finalFile = [NSString stringWithFormat:@"%@-%u", fileBase, number];
    }
    return finalFile;
}

#pragma mark - Business Logic

- (BOOL)startRecording:(NSError **)error
{
    NSError *audioError = [self activateAudioSession];
    if (audioError == nil) {
        self.selfRef = self;
        self.audioRecorder.delegate = self;
        if ([self.audioRecorder recordForDuration:TelestrationConstants.maxRecordDuration]) {
            self.audioRecorderTimer = [NSTimer scheduledTimerWithTimeInterval:[TelestrationConstants recordingFrameDurationInSecs] target:self selector:@selector(syncCurrentTime:) userInfo:nil repeats:YES];
            self.recording = YES;
        } else {
            self.selfRef = nil;
            self.audioRecorder.delegate = nil;
            audioError = [NSError errorWithText:VstratorStrings.ErrorAudioRecorderRecordText];
        }
    }
    self.error = audioError;
    if (error != nil)
        *error = self.error;
    return (self.error == nil);
}

- (void)stopRecording
{
    if (self.recording) {
        [self.audioRecorder stop];
    }
}

- (void)stopAndDeleteRecording
{
    [self stopRecording];
    if (![self.audioRecorder deleteRecording])
        NSLog(@"Error deleting the recording");
}

- (void)finishRecording
{
    [self clearRecording];
}

- (void)interruptRecording:(NSError *)error
{
    [self clearRecording];
    if (error != nil)
        self.error = error;
}

- (void)syncCurrentTime:(id)data
{
    if (self.audioRecorder != nil && self.audioRecorder.recording)
        self.currentTime = self.audioRecorder.currentTime;
}

- (void)clearRecording
{
    // timer
    if (self.audioRecorderTimer != nil) {
        [self.audioRecorderTimer invalidate];
        self.audioRecorderTimer = nil;
    }
    // props
    self.recording = NO;
    self.currentTime = 0;
    // props
    self.audioRecorder.delegate = nil;
    self.selfRef = nil;
    // AVAudioSession
    [self deactivateAudioSession];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"audioRecorderDidFinishRecording%@", flag ? @"" : @" - Unsuccessfully");
    [self finishRecording];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"audioRecorderEncodeErrorDidOccur: %@", [error description]);
    [self interruptRecording:error];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    NSLog(@"audioRecorderBeginInterruption");
    [self interruptRecording:nil];
}

@end

//
//  TelestrationRecordingController.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TelestrationRecordingControllerDelegate;


@interface TelestrationRecordingController : NSObject

@property (nonatomic, weak) id<TelestrationRecordingControllerDelegate> delegate;

@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, copy, readonly) NSString *fileName;
@property (atomic, readonly) NSTimeInterval currentTime;
@property (atomic, readonly) BOOL recording;

- (id)initWithDelegate:(id<TelestrationRecordingControllerDelegate>)delegate fileName:(NSString *)fileName error:(NSError **)error;
- (BOOL)startRecording:(NSError **)error;
- (void)stopRecording;
- (void)stopAndDeleteRecording;

@end


@protocol TelestrationRecordingControllerDelegate <NSObject>

@optional
- (void)telestrationRecordingController:(TelestrationRecordingController *)controller didChangeCurrentTime:(NSTimeInterval)currentTime;
- (void)telestrationRecordingController:(TelestrationRecordingController *)controller didChangeRecordingState:(BOOL)recording;
                                                                                                            
@end

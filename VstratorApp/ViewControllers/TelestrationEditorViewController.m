//
//  TelestrationEditorViewController.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationEditorViewController.h"
#import "TelestrationPlayerViewController.h"

#import "AccountController2.h"
#import "ArrowTelestrationShapeView.h"
#import "BaseTelestrationShapeView.h"
#import "CircleTelestrationShapeView.h"
#import "Clip.h"
#import "FlurryLogger.h"
#import "Frame.h"
#import "FrameStackModel.h"
#import "FreehandTelestrationShapeView.h"
#import "LineTelestrationShapeView.h"
#import "MediaPropertiesViewController.h"
#import "MediaService.h"
#import "SquareTelestrationShapeView.h"
#import "SystemInformation.h"
#import "TaskManager.h"
#import "TelestrationModel.h"
#import "TelestrationPlaybackView.h"
#import "TelestrationRecordingController.h"
#import "VstrationController.h"
#import "VstrationSessionModel.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"
#import "NSFileManager+Extensions.h"

static inline UIColor* HEXCOLOR(uint hex)
{
    return [UIColor colorWithRed:((hex>>16)&0xFF)/255.0 green:((hex>>8)&0xFF)/255.0 blue:(hex&0xFF)/255.0 alpha:1.0];
}

@interface TelestrationEditorViewController() <MediaPropertiesViewControllerDelegate, TelestrationPlaybackViewDelegate,  TelestrationPlayerViewControllerDelegate, TelestrationRecordingControllerDelegate> {
    BOOL _viewDidAppearOnce;
    BOOL _applicationDidResignActive;
}

// objects: ...controller
@property (nonatomic, strong) VstrationController *controller;
// ...current shape & color
@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, strong) BaseTelestrationShapeView *currentShapeView;
@property (nonatomic) CGPoint currentShapeStartPoint;
@property (nonatomic) CGPoint currentShapeEndPoint;
@property (nonatomic) TelestrationShapes currentShape;
// ...recorder
@property (nonatomic, strong) TelestrationRecordingController *recorder;
@property (nonatomic, strong) Callback0 recordStopCallback;
@property (nonatomic, strong) NSTimer *recordCountdownTimer;
// ...misc
@property (nonatomic) BOOL shouldPlayOnRecordStart;
@property (nonatomic) BOOL shouldClearOnUndoAction;
@property (nonatomic, strong) NSDate *recordStartDate;

// views: ...area

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet TelestrationPlaybackView *playbackView;
@property (nonatomic, weak) IBOutlet UIView *shapesView;
// ...tools & colors pickers
@property (nonatomic, weak) IBOutlet UIView *toolsView;
@property (nonatomic, weak) IBOutlet UIButton *trashButton;
@property (nonatomic, weak) IBOutlet UIButton *colorsButton;
@property (nonatomic, weak) IBOutlet UIButton *undoButton;
@property (nonatomic, strong) IBOutlet UIView *colorsPickerView;
@property (nonatomic, weak) IBOutlet UIButton *shapesButton;
@property (nonatomic, strong) IBOutlet UIView *shapesPickerView;
@property (nonatomic, weak) IBOutlet UIButton *shapeFreehandButton;
@property (nonatomic, weak) IBOutlet UIButton *shapeRectangleButton;
@property (nonatomic, weak) IBOutlet UIButton *shapeCircleButton;
@property (nonatomic, weak) IBOutlet UIButton *shapeLineButton;
@property (nonatomic, weak) IBOutlet UIButton *shapeArrowButton;
@property (nonatomic, weak) IBOutlet UIButton *zoomButton;
@property (nonatomic, weak) IBOutlet UIButton *flipButton;
@property (nonatomic, weak) IBOutlet UIImageView *shapeViewBackgroundImage;
@property (nonatomic, weak) IBOutlet UIImageView *colorViewBackgroundImage;
// ...timeline
@property (nonatomic, weak) IBOutlet UIView *timelineView;
@property (nonatomic, weak) IBOutlet UIImageView *timelineSliderImageView;
@property (nonatomic, weak) IBOutlet UIButton *timelineShowButton;
@property (weak, nonatomic) IBOutlet UISlider *timelineSlider;
// ...toolbar
@property (nonatomic, weak) IBOutlet UIImageView *toolbarImageView;
@property (nonatomic, weak) IBOutlet UIButton *recordStartButton;
@property (nonatomic, weak) IBOutlet UIButton *recordStopButton;
@property (nonatomic, weak) IBOutlet UILabel *recordCounterLabel;
@property (nonatomic, weak) IBOutlet UIButton *playbackSeekBackwardButton;
@property (nonatomic, weak) IBOutlet UIButton *playbackSeekForwardButton;
@property (nonatomic, weak) IBOutlet UIButton *playbackPlayButton;
@property (nonatomic, weak) IBOutlet UIButton *playbackPauseButton;

@end

#pragma mark -

@implementation TelestrationEditorViewController

#pragma mark Properties

- (BOOL)statusBarHidden
{
    return YES;
}

#pragma mark Navigation Staff

- (void)dismissWithCancel
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(telestrationEditorViewControllerDidCancel:)])
            [self.delegate telestrationEditorViewControllerDidCancel:self];
    }];
}

- (void)dismissWithSave:(Session *)session
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(telestrationEditorViewControllerDidSave:session:)])
            [self.delegate telestrationEditorViewControllerDidSave:self session:session];
    }];
}

#pragma mark TelestrationRecorderDelegate

- (void)telestrationRecordingController:(TelestrationRecordingController *)controller didChangeCurrentTime:(NSTimeInterval)currentTime
{
    if (controller.recording)
        [self addFrameToModel:YES];
}

- (void)telestrationRecordingController:(TelestrationRecordingController *)controller didChangeRecordingState:(BOOL)recording
{
    if (recording)
        return;
    Callback0 callback = self.recordStopCallback;
    [self addFrameToModel:NO];
    [self playbackPause:self];
    [self clearRecording];
    if (callback != nil) callback();
}

#pragma mark Playback

- (BOOL)playbackViewPlaying
{
    return self.playbackView.playing;
}

- (NSTimeInterval)playbackAtEOF
{
    return self.playbackView.eof;
}

- (NSInteger)playbackCurrentFrameNumber
{
    return self.playbackView.currentFrameNumber;
}

- (NSInteger)playbackCurrentFrameNumber2
{
    return -1;
}

- (FrameTransform *)playbackCurrentTransform
{
    return self.playbackView.currentFrameTransform;
}

- (FrameTransform *)playbackCurrentTransform2
{
    return nil;
}

- (IBAction)playbackPause:(id)sender
{
    [self.playbackView pause];
}

- (IBAction)playbackPlay:(id)sender
{
    [self.playbackView play];
}

- (IBAction)seekToPreviousFrame:(id)sender
{
    [self.playbackView seekToPrevFrame];
}

- (IBAction)seekToNextFrame:(id)sender
{
    [self.playbackView seekToNextFrame];
}

- (IBAction)seekToSliderPosition:(id)sender
{
    [self.playbackView seekToSliderPosition:NO];
}

- (IBAction)timelineSliderDidEndSliding:(id)sender
{
    [self.playbackView seekToSliderPosition:YES];
}

#pragma mark Recording

- (void)recordStartingEvent
{
    self.shouldPlayOnRecordStart = self.playbackView.playing;
    if (self.shouldPlayOnRecordStart)
        [self.playbackView pause];
}

- (void)recordStartedEvent
{
    if (self.shouldPlayOnRecordStart)
        [self.playbackView play];
}

- (BOOL)startRecording:(NSError **)error
{
    // UI
    self.recordStartButton.hidden = YES;
    self.recordStopButton.hidden = NO;
    self.recordCounterLabel.hidden = NO;
    // fields
    self.recordStartDate = nil;
    self.recordStopCallback = nil;
    // timer
    [self recordCountdownUpdate];
    self.recordCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:0.1333f target:self selector:@selector(recordCountdownUpdate) userInfo:nil repeats:YES];
    // recorder
    return [self.recorder startRecording:error];
}

- (void)clearRecording
{
    // timer
    if (self.recordCountdownTimer != nil) {
        [self.recordCountdownTimer invalidate];
        self.recordCountdownTimer = nil;
    }
    // fields
    self.recordStartDate = nil;
    self.recordStopCallback = nil;
    // UI
    self.recordStartButton.hidden = NO;
    self.recordStopButton.hidden = YES;
    self.recordCounterLabel.hidden = YES;
}

- (void)stopRecordingIfActive
{
    [self stopRecordingWithCallback:nil];
}

- (void)stopRecordingWithCallback:(Callback0)callback
{
    if (self.recorder.recording) {
        self.recordStopCallback = callback;
        [self.recorder stopRecording];
    } else {
        if (callback) callback();
    }
}

- (void)saveRecordingAndLaunchPlayback
{
    // create meta for the recording length
	self.controller.model.audioFileDuration = @(self.recorder.currentTime);
    self.controller.model.audioFileName = self.recorder.fileName;
    //NSLog(@"View frame: %f, %f", self.shapesView.frame.size.width, self.shapesView.frame.size.height);
    // playback to confirm
    NSError *error = nil;
    TelestrationPlayerViewController *vc = [[TelestrationPlayerViewController alloc] initForSaveWithController:self.controller delegate:self error:&error];
    if (error == nil) {
        [self presentViewController:vc animated:NO completion:nil];
    } else {
        [UIAlertViewWrapper alertError:error];
    }
}

- (void)recordCountdownUpdate
{
    if (self.recordStartDate == nil)
        self.recordStartDate = NSDate.date;
    NSTimeInterval timeDifference = [NSDate.date timeIntervalSinceDate:self.recordStartDate];
    NSInteger milliseconds = (NSInteger)((timeDifference - (NSInteger)timeDifference) * 100);
    NSInteger seconds = (int)timeDifference % 60;
    timeDifference -= seconds;
    timeDifference /= 60;
    NSInteger minutes = (int)timeDifference % 60;
    self.recordCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", minutes, seconds, milliseconds];
}

- (IBAction)recordStartAction:(id)sender
{
    // check
    if (self.recorder.recording)
        return;
    // perform
    [self recordStartingEvent];
    NSError *error = nil;
    if ([self startRecording:&error]) {
        __block __weak TelestrationEditorViewController *blockSelf = self;
        self.recordStopCallback = ^{ [blockSelf saveRecordingAndLaunchPlayback]; };
        [self recordStartedEvent];
    } else {
        [self clearRecording];
        [UIAlertViewWrapper alertError:error];
    }
}

- (IBAction)recordStopAction:(id)sender
{
    // check
    if (!self.recorder.recording)
        return;
    // perform
    __block __weak TelestrationEditorViewController *blockSelf = self;
    [self stopRecordingWithCallback:^{ [blockSelf saveRecordingAndLaunchPlayback]; }];
}

#pragma mark TrashAlertDelegate replacement

- (IBAction)trashAction:(id)sender
{
    __block __weak TelestrationEditorViewController *blockSelf = self;
    UIAlertViewWrapper *wrapper = [UIAlertViewWrapper wrapperWithCallback:^(id result) {
        if ([result isKindOfClass:NSNumber.class] && ((NSNumber *)result).intValue == 1) {
            [blockSelf stopRecordingWithCallback:^{
                [blockSelf clearTelestrationDataAndFiles];
                [blockSelf dismissWithCancel];
            }];
        }
    }];
    [wrapper showMessage:VstratorStrings.MediaClipSessionEditDoYouWantToCancel
                   title:VstratorStrings.MediaClipSessionEditCancelButtonTitle
       cancelButtonTitle:VstratorStrings.MediaClipSessionEditNoButtonTitle
       otherButtonTitles:VstratorStrings.MediaClipSessionEditYesButtonTitle, nil];
}

#pragma mark Pickers

- (void)hidePickers
{
    self.shapesPickerView.hidden = YES;
    self.colorsPickerView.hidden = YES;
}

- (IBAction)showColorsAction:(id)sender
{
    self.colorsPickerView.hidden = !self.colorsPickerView.hidden;
    self.shapesPickerView.hidden = YES;
    [self offZoom];
}

- (IBAction)selectColorAction:(UIButton *)sender
{
    // hide popup
    [self hidePickers];
    // save color
    self.currentColor = HEXCOLOR(sender.tag);
    // update button
    for (UIView *view1 in self.colorsButton.subviews) {
        if (view1.tag == 1)
            [view1 removeFromSuperview];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 7, 25, 25)];
    view.tag = 1;
    view.backgroundColor = self.currentColor;
    view.userInteractionEnabled = NO;
    [self.colorsButton addSubview:view];
    // log
    //NSLog(@"Changing color to %@", self.currentColor);
    [self offZoom];
}

- (IBAction)showShapesAction:(id)sender
{
    self.shapesPickerView.hidden = !self.shapesPickerView.hidden;
    self.colorsPickerView.hidden = YES;
    [self offZoom];
}

- (IBAction)selectShapeAction:(UIButton *)sender
{
    // hide popup
    [self hidePickers];
    // save shape
    self.currentShape = sender.tag;
    // update button
    for (UIView *view1 in self.shapesButton.subviews) {
        if (view1.tag == 1)
            [view1 removeFromSuperview];
    }
    UIImage *image = [sender imageForState:UIControlStateNormal];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = 1;
    imageView.frame = CGRectMake(7, 2, 30, 30);
    imageView.userInteractionEnabled = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.shapesButton addSubview:imageView];
    [self offZoom];
}

- (IBAction)undoOrClearAction:(id)sender
{
    // hide controls
    [self hidePickers];
    // perform
    if (self.shouldClearOnUndoAction) {
        [self removeAllTelestrationShapes];
        self.shouldClearOnUndoAction = NO;
    } else {
        [self removeLastTelestrationShape];
        self.shouldClearOnUndoAction = YES;
    }
    [self offZoom];
}

- (void)offZoom
{
    self.shapesView.userInteractionEnabled = YES;
    self.zoomButton.selected = NO;
    self.flipButton.hidden = YES;
}

- (void)setHiddenForFlipButton:(BOOL)hidden
{
    self.flipButton.hidden = hidden;
}

- (IBAction)zoomAction:(id)sender
{
    self.shapesView.userInteractionEnabled = !self.shapesView.userInteractionEnabled;
    self.zoomButton.selected = !self.zoomButton.selected;
    [self setHiddenForFlipButton:!self.zoomButton.selected];
}

- (IBAction)flipAction:(id)sender
{
    [self.playbackView flipCurrentFrame];
}

#pragma mark Timeline

- (IBAction)timelineHideAction:(id)sender
{
    // hide controls
    [self hidePickers];
    // perform
    self.timelineView.hidden = YES;
    self.timelineShowButton.hidden = NO;
}

- (IBAction)timelineShowAction:(id)sender
{
    // hide controls
    [self hidePickers];
    // perform
    self.timelineView.hidden = NO;
    self.timelineShowButton.hidden = YES;
}

#pragma mark Touch checking

- (void)startNewTelestration:(TelestrationShapes)shape withPoint:(CGPoint)origin
{
    CGRect shapeFrame = CGRectMake(origin.x, origin.y, 45, 45);
    switch (shape) {
        case TelestrationShapeCircle:
            self.currentShapeView = [[CircleTelestrationShapeView alloc] initWithFrame:shapeFrame];
            break;
        case TelestrationShapeRectangle:
            self.currentShapeView = [[SquareTelestrationShapeView alloc] initWithFrame:shapeFrame];
            break;
        case TelestrationShapeLine:
            self.currentShapeView = [[LineTelestrationShapeView alloc] initWithFrame:self.shapesView.frame];
            ((LineTelestrationShapeView *)self.currentShapeView).start = origin;
            break;
        case TelestrationShapeArrow:
            self.currentShapeView = [[ArrowTelestrationShapeView alloc] initWithFrame:self.shapesView.frame];
            ((ArrowTelestrationShapeView *)self.currentShapeView).start = origin;
            break;
        case TelestrationShapeFreehand:
            self.currentShapeView = [[FreehandTelestrationShapeView alloc] initWithFrame:self.shapesView.frame];
            [((FreehandTelestrationShapeView *)self.currentShapeView).points addObject:[NSValue valueWithCGPoint:origin]];
            break;
        default:
            break;
    }
    self.currentShapeView.color = self.currentColor;
}

-(CGPoint)pointFromTouches:(NSSet*)touches
{
    CGPoint point = [[touches anyObject] locationInView:self.shapesView];
    point.x = fmaxf(fminf(point.x, self.shapesView.frame.size.width), 0);
    point.y = fmaxf(fminf(point.y, self.shapesView.frame.size.height), 0);
    return point;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //if(!self.messageView.hidden)
    //    return;
    [self hidePickers];
    //self.trashButton.tag = (NSInteger)self.trashButton.hidden;
    //self.trashButton.hidden = YES;
    //self.timelineView.tag = (NSInteger)self.timelineView.hidden;
    //self.timelineView.hidden = YES;
    //self.timelineShowButton.tag = (NSInteger)self.timelineShowButton.hidden;
    //self.timelineShowButton.hidden = YES;
    self.shouldClearOnUndoAction = NO;
    self.currentShapeStartPoint = [self pointFromTouches:touches];
    [self startNewTelestration:self.currentShape withPoint:self.currentShapeStartPoint];
    [self.controller.telestrations push:self.currentShapeView];
    [self.shapesView addSubview:self.currentShapeView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //if(!self.messageView.hidden)
    //    return;
    self.currentShapeEndPoint = [self pointFromTouches:touches];
    if (self.currentShapeView) {
        if (self.currentShape == TelestrationShapeFreehand) {
            [((FreehandTelestrationShapeView*)self.currentShapeView) addPoint:self.currentShapeEndPoint];
            [self.currentShapeView setNeedsDisplay];
        } else if(self.currentShape == TelestrationShapeLine || self.currentShape == TelestrationShapeArrow) {
            ((LineTelestrationShapeView *)self.currentShapeView).end = self.currentShapeEndPoint;
            [self.currentShapeView setNeedsDisplay];
        } else {
            self.currentShapeView.frame = CGRectMake(self.currentShapeStartPoint.x, self.currentShapeStartPoint.y, self.currentShapeEndPoint.x - self.currentShapeStartPoint.x, self.currentShapeEndPoint.y - self.currentShapeStartPoint.y);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //if(!self.messageView.hidden)
    //    return;
    //self.trashButton.hidden = (BOOL)self.trashButton.tag;
    //self.timelineView.hidden = (BOOL)self.timelineView.tag;
    //self.timelineShowButton.hidden = (BOOL)self.timelineShowButton.tag;
    //Store the final shape.
    self.currentShapeView.startTime = self.recorder.currentTime;
    self.currentShapeView = nil;
}

- (void)addFrameToModel:(BOOL)smartMode
{
    NSTimeInterval currTime = self.recorder.currentTime;
    NSInteger currFrameNumber = self.playbackCurrentFrameNumber;
    NSInteger currFrameNumber2 = self.playbackCurrentFrameNumber2;
    FrameTransform *currTransform = self.playbackCurrentTransform;
    FrameTransform *currTransform2 = self.playbackCurrentTransform2;
    bool perform = YES;
    if (smartMode) {
        Frame *lastFrame = [self.controller.frames.stack lastObject];
        perform = (lastFrame == nil ||
                   lastFrame.frameNumber != currFrameNumber ||
                   lastFrame.frameNumber2 != currFrameNumber2 ||
                   ![lastFrame.frameTransform isEqual:currTransform] ||
                   (currTransform2 != nil && ![lastFrame.frameTransform2 isEqual:currTransform2]));
    } else {
        perform = YES;
    }
    if (perform) {
        //NSLog(@"addFrameToModel: frame0 #: %u\tframe1 #:%u\t time: %f", currFrameNumber, currFrameNumber2, currTime);
        [self.controller.frames addFrameWithTime:currTime
                                     frameNumber:currFrameNumber
                                    frameNumber2:currFrameNumber2
                                  frameTransform:currTransform
                                 frameTransform2:currTransform2];
    }
}

#pragma mark Internal methods

- (BOOL)playbackViewSetupWithError:(NSError**)error
{
    BOOL result = [self.playbackView playbackViewSetupWithDuration:self.controller.model.originalClip.duration
                                                       playbackUrl:self.controller.model.playbackURL
                                              playbackImagesFolder:self.controller.model.originalClip.playbackImagesFolder
                                                         frameRate:self.controller.model.originalClip.frameRate.floatValue
                                                          delegate:self
                                                             error:error];
    if (result) {
        CGSize size = CGSizeMake(self.controller.model.originalClip.width.intValue, self.controller.model.originalClip.height.intValue);
        [self setPlaybackView:self.playbackView initZoomForSize:size];
    }
    return result;
}

- (void)setPlaybackView:(TelestrationPlaybackView*)playbackView initZoomForSize:(CGSize)size
{
    [playbackView setInitZoomForSize:size isSideBySide:NO];
}

- (void)waitForReadiness
{
    [self waitForReadiness:^AVPlayerStatus {
        return self.playbackView.playbackStatus;
    }];
}

- (void)waitForReadiness:(AVPlayerStatus(^)())statusCallback
{
    AVPlayerStatus status = statusCallback();
    if (status == AVPlayerStatusFailed) {
        NSLog(@"AVPlayerStatusFailed in waitForReadiness");
        [self hideBGActivityIndicator:[NSError errorWithText:VstratorStrings.ErrorLoadingSelectedSession]];
    } else if (status == AVPlayerStatusReadyToPlay) {
        [self hideBGActivityIndicator];
    } else {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self waitForReadiness];
        });
    }
}

- (void)removeLastTelestrationShape
{
    BaseTelestrationShapeView *t = [self.controller.telestrations lastItem];
    if (t == nil)
        return;
    // remove from the view
    //NSLog(@"Undo time set to: %f", self.recorder.currentTime);
    t.endTime = self.recorder.currentTime;
    [t removeFromSuperview];
    // remove from the model
    if (!self.recorder.recording)
        [self.controller.telestrations pop];
}

- (void)removeAllTelestrationShapes
{
    // remove from the view
    BaseTelestrationShapeView *t = nil;
    do {
        t = [self.controller.telestrations lastItem];
        if (t != nil && t.endTime < 0) {
            //NSLog(@"Clear time set to: %f", self.recorder.currentTime);
            t.endTime = self.recorder.currentTime;
            [t removeFromSuperview];
        }
    } while (t);
    // remove from the model
    if (!self.recorder.recording)
        [self.controller.telestrations clear];
}

- (void)clearTelestrationDataAndFiles
{
    // shapes & controller
    [self removeAllTelestrationShapes];
    [self.controller clear];
    self.controller.model.telestrationData = nil;
    // audio file
    NSError *error = nil;
    NSString *audioFilePath = self.controller.model.audioFileURL.path;
    if ([NSFileManager.defaultManager fileExistsAtPath:audioFilePath])
        [NSFileManager.defaultManager removeItemAtPath:audioFilePath error:&error];
	if (error)
		NSLog(@"Error deleting audio file: %@", error);
}

- (void)saveSessionAndPop:(Session *)session
{
    [MediaService.mainThreadInstance saveChanges:[self hideBGActivityCallback:^(NSError *error) {
        if (error == nil)
            [self dismissWithSave:session];
    }]];
}

- (void)createSessionAndPopWithTitle:(NSString *)title
                           sportName:(NSString *)sportName
                          actionName:(NSString *)actionName
                                note:(NSString *)note
{
    // store data
    NSLog(@"Filename to export: %@", self.controller.model.audioFileURL.path);
    NSError *error0 = nil;
    [self.controller storeWithSize:self.shapesView.frame.size error:&error0];
    if (error0 != nil) {
        NSLog(@"Error storing telestration data: %@", error0.userInfo);
        [UIAlertViewWrapper alertString:VstratorStrings.ErrorSavingSession
                                  title:VstratorStrings.ErrorTitleCantSaveSession];
        return;
    }
    //TODO: check for existing session (Editor mode)
    // change media data
    self.controller.model.title = title;
    self.controller.model.sportName = sportName;
    self.controller.model.actionName = actionName;
    self.controller.model.note = note;
    // save
    [self showBGActivityIndicator:VstratorStrings.MediaClipSessionCreationSavingSessionActivityTitle];
    [MediaService.mainThreadInstance findActionWithName:actionName sportName:sportName callback:^(NSError *error1, Action *action) {
        if (error1 != nil) {
            [self hideBGActivityIndicator:error1];
            return;
        }
        [MediaService.mainThreadInstance findClipWithIdentity:self.controller.model.originalClip.identity callback:^(NSError *error2, Clip *clip) {
            if (error2 != nil) {
                [self hideBGActivityIndicator:error2];
                return;
            }
            [MediaService.mainThreadInstance findUserWithIdentity:AccountController2.sharedInstance.userIdentity callback:^(NSError *error3, User *author) {
                if (error3 != nil) {
                    [self hideBGActivityIndicator:error3];
                    return;
                }
                if (self.controller.model.isSideBySide) {
                    // side-by-side
                    [MediaService.mainThreadInstance findClipWithIdentity:self.controller.model.originalClip2.identity callback:^(NSError *error4, Clip *clip2) {
                        if (error4 == nil) {
                            // ...create
                            Session *session = [Session createSideBySideWithClip:clip clip2:clip2 author:author inContext:clip.managedObjectContext];
                            [self.controller.model updateSession:session withAction:action];
                            // ...log
                            [FlurryLogger logTypedEvent:FlurryEventTypeVideoSideBySide
                                         withParameters:@{ @"Video Key": [NSString isNilOrWhitespace:clip.videoKey] ? @"" : clip.videoKey,
                                                           @"Pro Video": [FlurryLogger stringFromBool:clip.isProMedia],
                                                           @"Video 2 Key": [NSString isNilOrWhitespace:clip2.videoKey] ? @"" : clip2.videoKey,
                                                           @"Pro Video 2": [FlurryLogger stringFromBool:clip2.isProMedia],
                                                           @"Result Session Duration": [FlurryLogger stringFromDouble:session.duration.doubleValue] }];
                            // ...save
                            [self saveSessionAndPop:session];
                        } else {
                            [self hideBGActivityIndicator:error4];
                        }
                    }];
                } else {
                    // session: ...create
                    Session *session = [Session createSessionWithClip:clip author:author inContext:clip.managedObjectContext];
                    [self.controller.model updateSession:session withAction:action];
                    // ...log
                    [FlurryLogger logTypedEvent:FlurryEventTypeVideoVstrate
                                 withParameters:@{ @"Video Key": [NSString isNilOrWhitespace:clip.videoKey] ? @"" : clip.videoKey,
                                                   @"Pro Video": [FlurryLogger stringFromBool:clip.isProMedia],
                                                   @"Result Session Duration": [FlurryLogger stringFromDouble:session.duration.doubleValue] }];
                    // ...save
                    [self saveSessionAndPop:session];
                }
            }];
        }];
    }];
}

- (void)setPlaybackViewsToNil
{
    [self.playbackView setViewsToNil];
    self.playbackView.delegate = nil;
    self.playbackView = nil;
}

#pragma mark MediaPropertiesViewControllerDelegate

- (void)mediaPropertiesViewControllerDidCancel:(MediaPropertiesViewController *)sender
{
    [self trashAction:self.trashButton];
}

- (void)mediaPropertiesViewController:(MediaPropertiesViewController *)sender didAction:(MediaPropertiesAction)action
{
    if (action == MediaPropertiesActionSave) {
        [self createSessionAndPopWithTitle:sender.mediaTitle sportName:sender.mediaSportName actionName:sender.mediaActionName note:sender.mediaNote];
    }
}

#pragma mark TelestrationPlayerViewControllerDelegate

- (void)telestrationPlayerViewControllerDidCancel:(TelestrationPlayerViewController *)sender
{
    [self clearTelestrationDataAndFiles];
    [self.playbackView seekToStart];
}

- (void)telestrationPlayerViewControllerDidSave:(TelestrationPlayerViewController *)sender
{
    NSError* error = nil;
    [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:self.controller.model.audioFileURL error:&error];
    if (error) {
        NSLog(@"Cannot set skip backup attribute for audio file '%@'", self.controller.model.audioFileURL);
    }
    VstrationSessionModel *model = self.controller.model;
    UIViewController *vc = [[MediaPropertiesViewController alloc] initWithDelegate:self sourceURL:[NSURL URLWithString:model.url] title:model.title sportName:model.sportName actionName:model.actionName note:model.note vstrationMode:YES];
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark Application Events

- (void)savePlaybackTime
{
    [self.playbackView savePlayerTime];
}

- (void)restorePlaybackTime:(void(^)())callback
{
    [self.playbackView restorePlayerTime:callback];
}

- (void)applicationWillResignActive:(NSNotification*)notification
{
    [self showBGActivityIndicator:nil lockViews:YES];
    [self savePlaybackTime];
    [self playbackPause:self];
    [self stopRecordingIfActive];
}

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    [self clearTelestrationDataAndFiles];
    [self restorePlaybackTime:^{
        [self hideBGActivityIndicator];
    }];
}

#pragma mark Ctor

- (BOOL)setupWithSessionModel:(VstrationSessionModel *)model delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error
{
    NSParameterAssert(error);
    *error = nil;
    // properties
    _delegate = delegate;
    self.controller = [[VstrationController alloc] init];
    if ([self.controller load:model error:error]) {
        // init recorder & player
        self.recorder = [[TelestrationRecordingController alloc] initWithDelegate:self fileName:self.controller.model.audioFileName error:error];
        if (*error) {
            *error = [NSError errorWithError:*error text:VstratorStrings.ErrorAudioRecorderInitText];
        }
    } else {
        *error = [NSError errorWithError:*error text:VstratorStrings.ErrorLoadingSelectedClip];
    }
    return !*error;
}

- (id)initWithClip:(Clip *)clip delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error
{
    VstrationSessionModel *model = [[VstrationSessionModel alloc] initWithClip:clip];
    return [self initWithSessionModel:model delegate:delegate error:error];
}

//NOTE: commented because:
// 1) it's required to properly implement SAVE functionality for editor mode
// 2) originalClip and originalClip2 MUST BE and MUST HAVE their width/height properly set
//- (id)initWithSession:(Session *)session delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error
//{
//    VstrationSessionModel *model = [[VstrationSessionModel alloc] initWithSession:session];
//    return [self initWithSessionModel:model delegate:delegate error:error];
//}

- (id)initWithSessionModel:(VstrationSessionModel *)model delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error
{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        [self setupWithSessionModel:model delegate:delegate error:error];
    }
    return self;
}

- (void)dealloc
{
    // Object(s)
    //self.playbackView.delegate = nil;
    self.recorder.delegate = nil; // recorder can keep itself to complete all changes it needs, thus remove the link
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.trashButton setTitle:VstratorStrings.MediaClipSessionCreationBackButtonTitle forState:UIControlStateNormal];
    [self.colorsButton setTitle:VstratorStrings.MediaClipSessionCreationColorsButtonTitle forState:UIControlStateNormal];
    [self.shapesButton setTitle:VstratorStrings.MediaClipSessionCreationToolsButtonTitle forState:UIControlStateNormal];
    [self.undoButton setTitle:VstratorStrings.MediaClipSessionCreationUndoButtonTitle forState:UIControlStateNormal];
    [self.timelineShowButton setTitle:VstratorStrings.MediaClipSessionCreationTimelineButtonTitle forState:UIControlStateNormal];
    [self.recordStartButton setTitle:VstratorStrings.MediaClipSessionCreationStartButtonTitle forState:UIControlStateNormal];
    [self.recordStopButton setTitle:VstratorStrings.MediaClipSessionCreationStopButtonTitle forState:UIControlStateNormal];
    [self.zoomButton setTitle:VstratorStrings.MediaClipSessionCreationZoomButtonTitle forState:UIControlStateNormal];
}

#pragma mark Gesture Recognizers

- (void)longPressBackward:(UILongPressGestureRecognizer*)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self seekToPrevFrameContinuously];
            break;
        case UIGestureRecognizerStateEnded:
            [self stopSeekContinuously];
            break;
        default:
            break;
    }
}

- (void)longPressForward:(UILongPressGestureRecognizer*)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self seekToNextFrameContinuously];
            break;
        case UIGestureRecognizerStateEnded:
            [self stopSeekContinuously];
            break;
        default:
            break;
    }
}

- (void)seekToPrevFrameContinuously
{
    [self.playbackView seekToPrevFrameContinuously];
    self.playbackSeekBackwardButton.selected = YES;
}

- (void)seekToNextFrameContinuously
{
    [self.playbackView seekToNextFrameContinuously];
    self.playbackSeekForwardButton.selected = YES;
}

- (void)stopSeekContinuously
{
    [self.playbackView pause];
    self.playbackSeekBackwardButton.selected = NO;
    self.playbackSeekForwardButton.selected = NO;
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLocalizableStrings];
    self.navigationBarView.hidden = YES;
    self.toolsView.layer.borderColor = [UIColor colorWithWhite:0.39 alpha:1.0].CGColor;
    self.toolsView.layer.borderWidth = 1.0;
    [self setupResizableImages];
    [self showBGActivityIndicator:VstratorStrings.MediaClipPlaybackLoadingActivityTitle];
    NSError *error = nil;
    [self playbackViewSetupWithError:&error];
    if (error) {
        [UIAlertViewWrapper alertError:error];
    }
    if ([SystemInformation isSystemVersionLessThan:@"7.0"])
        [self fixUiForIos7];
    [self setupGestureRecognizers];
}

- (void)setupGestureRecognizers
{
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBackward:)];
    [self.playbackSeekBackwardButton addGestureRecognizer:gestureRecognizer];
    gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressForward:)];
    [self.playbackSeekForwardButton addGestureRecognizer:gestureRecognizer];
}

- (void)setupColorPicker
{
    self.colorViewBackgroundImage.image = [UIImage resizableImageNamed:@"btn_session_tools_h_normal"];
    if (self.colorsPickerView.superview == nil) {
        self.colorsPickerView.frame = CGRectMake(self.containerView.frame.origin.x + self.colorsButton.frame.origin.x, self.colorsButton.frame.origin.y, self.colorsPickerView.frame.size.width, self.colorsPickerView.frame.size.height);
        [self.view addSubview:self.colorsPickerView];
    }
    for (UIView *view in self.colorsPickerView.subviews) {
        if ([view isKindOfClass:UIButton.class]) {
            [self selectColorAction:(UIButton *)view];
            break;
        }
    }
}

- (void)setupShapePicker
{
    self.shapeFreehandButton.tag = TelestrationShapeFreehand;
	self.shapeRectangleButton.tag = TelestrationShapeRectangle;
	self.shapeCircleButton.tag = TelestrationShapeCircle;
	self.shapeLineButton.tag = TelestrationShapeLine;
    self.shapeArrowButton.tag = TelestrationShapeArrow;
    
    self.shapeViewBackgroundImage.image = [UIImage resizableImageNamed:@"btn_session_tools_h_normal"];
    if (self.shapesPickerView.superview == nil) {
        self.shapesPickerView.frame = CGRectMake(self.containerView.frame.origin.x + self.shapesButton.frame.origin.x, self.shapesButton.frame.origin.y, self.shapesPickerView.frame.size.width, self.shapesPickerView.frame.size.height);
        [self.view addSubview:self.shapesPickerView];
    }
    for (UIView *view in self.shapesPickerView.subviews) {
        if ([view isKindOfClass:UIButton.class]) {
            [self selectShapeAction:(UIButton *)view];
            break;
        }
    }
}

- (void)setupResizableImages
{
    self.toolbarImageView.image = [UIImage resizableImageNamed:@"bg-telestration-bottom"];
    self.timelineSliderImageView.image = [UIImage resizableImageNamed:@"bg-telestration-slider"];
    
    [self.playbackSeekBackwardButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.playbackSeekBackwardButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
    [self.playbackSeekBackwardButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateSelected];
    [self.playbackSeekForwardButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.playbackSeekForwardButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
    [self.playbackSeekForwardButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateSelected];
    [self.playbackPauseButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.playbackPauseButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
    [self.playbackPlayButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.playbackPlayButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];

}

- (void)fixUiForIos7
{
    self.shapesButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.colorsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.undoButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 14, 0);
    self.undoButton.titleEdgeInsets = UIEdgeInsetsMake(0, -26, 0, 0);
    self.zoomButton.titleEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    CGRect frame = self.timelineSlider.frame;
    frame.origin.y = 5;
    self.timelineSlider.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self setupColorPicker];
    [self setupShapePicker];
    
    if (![self canAccessMicrophone]) {
        [UIAlertViewWrapper alertString:@"You need to grant access to the microphone to use this feature!"];
        [self dismissWithCancel];
        return;
    }
    
    if (_viewDidAppearOnce)
        return;
    _viewDidAppearOnce = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self waitForReadiness];
    });
}

- (BOOL)canAccessMicrophone
{
    __block BOOL canAccess = NO;
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        dispatch_semaphore_t ds = dispatch_semaphore_create(0);
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            canAccess = granted;
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
        dispatch_release(ds);
    } else {
        canAccess = YES;
    }
    return canAccess;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Recording
    [self stopRecordingIfActive];
    // Application Events
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setPlaybackViewsToNil];
    [self setToolsView:nil];
    [self setShapesView:nil];
    [self setShapeViewBackgroundImage:nil];
    [self setTrashButton:nil];
    [self setColorsPickerView:nil];
    [self setColorViewBackgroundImage:nil];
    [self setColorsButton:nil];
    [self setUndoButton:nil];
    [self setShapesButton:nil];
    [self setShapesPickerView:nil];
	[self setShapeFreehandButton:nil];
	[self setShapeRectangleButton:nil];
	[self setShapeCircleButton:nil];
	[self setShapeLineButton:nil];
    [self setShapeArrowButton:nil];
    [self setZoomButton:nil];
    [self setFlipButton:nil];
    [self setToolbarImageView:nil];
    [self setRecordStartButton:nil];
    [self setRecordStopButton:nil];
    [self setRecordCounterLabel:nil];
    [self setPlaybackSeekBackwardButton:nil];
    [self setPlaybackSeekForwardButton:nil];
    [self setPlaybackPlayButton:nil];
    [self setPlaybackPauseButton:nil];
    [self setTimelineView:nil];
    [self setTimelineSliderImageView:nil];
    [self setTimelineShowButton:nil];
    [self setTimelineSlider:nil];
    // Super
    [super viewDidUnload];
}

#pragma mark Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end

//
//  TelestrationEditViewController.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationEditViewController.h"
#import "TelestrationPlaybackViewController.h"
//#import "TelestrationSaveViewController.h"

#import "BaseTelestrationShapeView.h"
#import "CircleTelestrationShapeView.h"
#import "FrameStackModel.h"
#import "FreehandTelestrationShapeView.h"
#import "LineTelestrationShapeView.h"
#import "MediaService.h"
#import "PlayerView.h"
#import "RecordProgressView.h"
#import "SquareTelestrationShapeView.h"
#import "TelestrationModel.h"
#import "TelestrationRecordingController.h"
#import "VstrationController.h"
#import "VstrationMediaModel.h"
#import "VstratorExtensions.h"

#import <AVFoundation/AVPlayerItem.h>

@interface TelestrationEditViewController()
{
    UIColor *theCurrentColor;
    BaseTelestrationShapeView *theTelestrationShape;
    CGPoint theStart;
    CGPoint theEnd;
    TelestrationShapes theCurrentShape;
    TelestrationRecordingController *theRecorder;
    NSTimer *theRecorderCountdownTimer;
    BOOL theFrameChanged;
    NSDate *theUndoActionDate;
    NSDate *theRecordStartDate;
}

@property (nonatomic, strong) IBOutlet UIView *messageView;
@property (nonatomic, unsafe_unretained) IBOutlet UIView *toolsView;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *trashButton;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *colorButton;
@property (nonatomic, unsafe_unretained) IBOutlet UIView *colorPicker;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *shapeButton;
@property (nonatomic, unsafe_unretained) IBOutlet UIView *shapePicker;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *recordStartButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *recordStopButton;
@property (nonatomic, unsafe_unretained) IBOutlet RecordProgressView *recordIndicatorView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *recordCounterLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *timelineView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *timelineShowButton;

- (IBAction)showShapesAction:(id)sender;
- (IBAction)selectShapeAction:(UIButton *)sender;
- (IBAction)showColorsAction:(id)sender;
- (IBAction)selectColorAction:(UIButton *)sender;
- (IBAction)undoOrClearAction:(id)sender;
- (IBAction)recordStartAction:(id)sender;
- (IBAction)recordStopAction:(id)sender;

- (IBAction)trashAction:(id)sender;
- (IBAction)timelineHideAction:(id)sender;
- (IBAction)timelineShowAction:(id)sender;

// UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

// ContentActionDelegate
- (void)contentActionDidFinish:(id)sender
             withContentAction:(ContentAction)action;

// Forwards
- (void)addFrameToModel;
- (void)freeRecordingElements;
- (void)saveRecordingAndLaunchPlaybackIf;
- (void)recordCountdownUpdate;

@end

@implementation TelestrationEditViewController

#pragma mark - Defines

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0 alpha:1.0];

#pragma mark - Properties

@synthesize delegate = _delegate;
@synthesize messageView = _messageView;
@synthesize toolsView = _toolsView;
@synthesize trashButton = _trashButton;
@synthesize colorButton = _colorButton;
@synthesize colorPicker = _colorPicker;
@synthesize shapeButton = _shapeButton;
@synthesize shapePicker = _shapePicker;
@synthesize recordStartButton = _recordStartButton;
@synthesize recordStopButton = _recordStopButton;
@synthesize recordCounterLabel = _recordCounterLabel;
@synthesize recordIndicatorView = _recordIndicatorView;
@synthesize timelineView = _timelineView;
@synthesize timelineShowButton = _timelineShowButton;

static void *CurrentTimeKeyPath = &CurrentTimeKeyPath;
static void *IsRecordingKeyPath = &IsRecordingKeyPath;

BOOL _saveRecordingAndLaunchPlaybackOnStopRecording = NO;

#pragma mark - Navigation Staff

- (void)rollbackAndDismissWithCancel
{
    [MediaService.threadInstance rollbackChanges:^(NSError *error) {
        [self.navigationController popViewControllerAnimated:VstratorConstants.ViewControllersNavigationPopAnimated];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(contentActionDidFinish:withContentAction:)]) {
            [self.delegate contentActionDidFinish:self withContentAction:ContentActionCancel];
        }
    }];
}

- (void)popWithSave
{
    [self.navigationController popViewControllerAnimated:VstratorConstants.ViewControllersNavigationPopAnimated];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(contentActionDidFinish:withChanges:)]) {
        [self.delegate contentActionDidFinish:self withChanges:YES];
    }
}

#pragma mark - KVO

- (void)addRecorderObservers
{
    [theRecorder addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:CurrentTimeKeyPath];
    [theRecorder addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionNew context:IsRecordingKeyPath];
}

- (void)removeRecorderObservers
{
    [theRecorder removeObserver:self forKeyPath:@"currentTime"];
    [theRecorder removeObserver:self forKeyPath:@"isRecording"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Record Indicator
    if(context == CurrentTimeKeyPath) {
        //TODO Detect the end of the video and toggle the play to pause.
        if (theFrameChanged) {
            //If the video is paused, then we're not playing back, so don't constantly update.
            if (self.player.rate == 0.0f) {
                theFrameChanged = NO;
            }
            [self addFrameToModel];
        }
        //Update the record button
        self.recordIndicatorView.progress = theRecorder.currentTime / kDuration;
        [self.recordIndicatorView setNeedsDisplay];
    } 
    // Hey, we're done! export, invalidate, whatever.
    else if (context == IsRecordingKeyPath) {
        if (!theRecorder.isRecording) {
            [self freeRecordingElements];
            [self removeRecorderObservers];
            [self saveRecordingAndLaunchPlaybackIf];
        }
    }
}

#pragma mark - Business Logic

- (BOOL)startRecording:(NSError **)error
{
    self.trashButton.hidden = YES;
    self.recordStartButton.hidden = YES;
    self.recordStopButton.hidden = NO;
    [self recordCountdownUpdate];
    self.recordCounterLabel.hidden = NO;
    theFrameChanged = YES;
    theRecorderCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(recordCountdownUpdate) userInfo:nil repeats:YES];
    [self addRecorderObservers];
    return [theRecorder startRecording:error];
}

- (void)freeRecordingElements
{
    // player
    [self pauseVideo];
    // timer
    if (theRecorderCountdownTimer != nil) {
        [theRecorderCountdownTimer invalidate];
        theRecorderCountdownTimer = nil;
    }
    // buttons
    self.trashButton.hidden = NO;
    self.recordStartButton.hidden = NO;
    self.recordStopButton.hidden = YES;
    self.recordCounterLabel.hidden = YES;
}

- (void)stopRecording:(BOOL)saveRecordingAndLaunchPlayback
{
    if (theRecorder.isRecording) {
        _saveRecordingAndLaunchPlaybackOnStopRecording = saveRecordingAndLaunchPlayback;
        [theRecorder stopRecording]; // KVO will take over clearRecordingObjects and so on
    } else {
        [self freeRecordingElements]; // just clear objects
    }
}

- (void)saveRecordingAndLaunchPlaybackIf
{
    if (!_saveRecordingAndLaunchPlaybackOnStopRecording)
        return;
    _saveRecordingAndLaunchPlaybackOnStopRecording = NO;
    // create meta for the recording length
	self.controller.media.audioFileDuration = [NSNumber numberWithFloat:theRecorder.currentTime];
    self.controller.media.audioFileName = theRecorder.fileName;
    NSLog(@"View frame: %f, %f", self.telestrationView.frame.size.width, self.telestrationView.frame.size.height);
    // playback to confirm
    NSError *error = nil;
    TelestrationPlaybackViewController *vc = [[TelestrationPlaybackViewController alloc] initForSaveWithVstrationController:self.controller delegate:self error:&error];
    if (error == nil) {
        [self.navigationController pushViewController:vc animated:NO];
    } else {
        [UIAlertViewWrapper alertError:error];
    }
}

- (void)recordCountdownUpdate
{
    if (theRecordStartDate == nil)
        theRecordStartDate = NSDate.date;
    NSTimeInterval timeDifference = [NSDate.date timeIntervalSinceDate:theRecordStartDate];
    NSInteger milliseconds = (NSInteger)((timeDifference - (NSInteger)timeDifference) * 100);
    NSInteger seconds = (int)timeDifference % 60;
    timeDifference -= seconds;
    timeDifference /= 60;
    NSInteger minutes = (int)timeDifference % 60;
    self.recordCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", minutes, seconds, milliseconds];
}

#pragma mark - IBActions

- (void)hidePopup
{
    self.shapePicker.hidden = YES;
    self.colorPicker.hidden = YES;
}

- (IBAction)trashAction:(id)sender 
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Cancel" message:@"Do you want to cancel this session?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag = 1;
    [alertView show];
}

- (IBAction)showColorsAction:(id)sender
{
    self.colorPicker.hidden = !self.colorPicker.hidden;
    self.shapePicker.hidden = YES;
}

- (IBAction)selectColorAction:(UIButton *)sender
{
    // hide popup
    [self hidePopup];
    // save color
    theCurrentColor = HEXCOLOR(sender.tag);
    // update button
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, 11, 25, 25)];
    view.tag = 1;
    view.backgroundColor = theCurrentColor;
    view.userInteractionEnabled = NO;
    for (UIView *view1 in self.colorButton.subviews) {
        if (view.tag == 1)
            [view1 removeFromSuperview];
    }
    [self.colorButton addSubview:view];
    // log
    NSLog(@"Changing color to %@", theCurrentColor);
}

- (IBAction)showShapesAction:(id)sender
{
    self.shapePicker.hidden = !self.shapePicker.hidden;
    self.colorPicker.hidden = YES;
}

- (IBAction)selectShapeAction:(UIButton *)sender
{
    // hide popup
    [self hidePopup];
    // save shape
    theCurrentShape = sender.tag;
    // update button
    UIImage *image = [sender imageForState:UIControlStateNormal];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = 1;
    imageView.frame = CGRectMake(8, 1, 40, 40);
    imageView.userInteractionEnabled = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    for (UIView *view1 in self.shapeButton.subviews) {
        if (view1.tag == 1)
            [view1 removeFromSuperview];
    }
    [self.shapeButton addSubview:imageView];
}

- (void)undoAction
{
    BaseTelestrationShapeView *t = [self.controller.telestrations lastItem];
    if (t != nil) {
        NSLog(@"Undo time set to: %f", theRecorder.currentTime);
        t.endTime = theRecorder.currentTime;
        [t removeFromSuperview];
        if (!theRecorder.isRecording) {
            [self.controller.telestrations pop];
        }
    }
}

- (void)clearAction
{
    BaseTelestrationShapeView *t = nil;
    do {
        t = [self.controller.telestrations lastItem];
        if (t != nil && t.endTime < 0) {
            NSLog(@"Clear time set to: %f", theRecorder.currentTime);
            t.endTime = theRecorder.currentTime;
            [t removeFromSuperview];
        }
    } while (t);
    if (!theRecorder.isRecording) {
        [self.controller.telestrations clear];
    }
}

- (IBAction)undoOrClearAction:(id)sender
{
    NSTimeInterval timeInterval = theUndoActionDate == nil ? 0 : [theUndoActionDate timeIntervalSinceNow];
    theUndoActionDate = NSDate.date;
    if (timeInterval < 1.0f) {
        [self clearAction];
    } else {
        [self undoAction];
    }
}

- (IBAction)recordStartAction:(id)sender 
{
    // check
    if (theRecorder.isRecording)
        return;
    // perform
    NSError *error = nil;
    if (![self startRecording:&error]) {
        [self stopRecording:NO];
        [UIAlertViewWrapper alertError:error];
    }
}

- (IBAction)recordStopAction:(id)sender
{
    // check
    if (!theRecorder.isRecording)
        return;
    // perform
    [self stopRecording:YES];
}

- (IBAction)timelineHideAction:(id)sender
{
    self.timelineView.hidden = YES;
    self.timelineShowButton.hidden = NO;
}

- (IBAction)timelineShowAction:(id)sender
{
    self.timelineView.hidden = NO;
    self.timelineShowButton.hidden = YES;
}

#pragma mark - Touch checking

- (void)startNewTelestration:(TelestrationShapes)shape withPoint:(CGPoint)origin
{
    CGRect shapeFrame = CGRectMake(origin.x, origin.y, 45, 45);
    switch (shape) {
        case TelestrationShapeCircle:
            theTelestrationShape = [[CircleTelestrationShapeView alloc] initWithFrame:shapeFrame];
            break;
        case TelestrationShapeRectangle:
            theTelestrationShape = [[SquareTelestrationShapeView alloc] initWithFrame:shapeFrame];
            break;
        case TelestrationShapeLine:
            theTelestrationShape = [[LineTelestrationShapeView alloc] initWithFrame:self.telestrationView.frame];
            ((LineTelestrationShapeView *)theTelestrationShape).start = origin;
            break;
        case TelestrationShapeFreehand:
            theTelestrationShape = [[FreehandTelestrationShapeView alloc] initWithFrame:self.telestrationView.frame];
            [((FreehandTelestrationShapeView *)theTelestrationShape).points addObject:[NSValue valueWithCGPoint:origin]];
            break;
        default:
            break;
    }
    theTelestrationShape.color = theCurrentColor;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.messageView.hidden) 
        return;
    //    playbackControlView.hidden = YES;
    //    toolsView.hidden = YES;
    self.trashButton.tag = (NSInteger)self.trashButton.hidden;
    self.trashButton.hidden = YES;
    theStart = [[touches anyObject] locationInView:self.telestrationView];
    [self startNewTelestration:theCurrentShape withPoint:theStart];
    [self.controller.telestrations push:theTelestrationShape];
    [self.telestrationView addSubview:theTelestrationShape];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.messageView.hidden)
        return;
    theEnd = [[touches anyObject] locationInView:self.telestrationView];
    if (theTelestrationShape) {
        if(theCurrentShape == TelestrationShapeFreehand) {
            [((FreehandTelestrationShapeView*)theTelestrationShape) addPoint:theEnd];
            [theTelestrationShape setNeedsDisplay];
        } else if(theCurrentShape == TelestrationShapeLine) {
            ((LineTelestrationShapeView *)theTelestrationShape).end = theEnd;
            [theTelestrationShape setNeedsDisplay];
        } else {
            theTelestrationShape.frame = CGRectMake(theStart.x, theStart.y, theEnd.x - theStart.x, theEnd.y - theStart.y);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.messageView.hidden)
        return;
    self.toolsView.hidden = NO;
    self.trashButton.hidden = (BOOL)self.trashButton.tag;
    //Store the final shape.
    theTelestrationShape.startTime = theRecorder.currentTime;
    theTelestrationShape = nil;
}

- (void)addFrameToModel
{
    NSLog(@"Frame #: %u\t At Time: %f", self.playerFrameNumber, theRecorder.currentTime);
    [self.controller.frames addFrameAtTime:self.playerFrameNumber atTime:theRecorder.currentTime];
}

#pragma mark - Subclassing

- (void)seek:(BOOL)forward
{
    theFrameChanged = YES;
    [super seek:forward];
}

- (void)playVideo
{
    theFrameChanged = YES;
    [super playVideo];
}

- (void)seekToTime
{
    theFrameChanged = YES;
    [super seekToTime];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        [self trashData];
        [self rollbackAndDismissWithCancel];
    }
}

#pragma mark - ContentActionDelegate

- (void)contentActionDidFinish:(id)sender
             withContentAction:(ContentAction)action
{
    if (action == ContentActionCancel) {
        [self trashData];
        [self rollbackAndDismissWithCancel];
    } else if (action == ContentActionRedo) {
        self.scrubSlider.value = 0.0;
        [self sliderChanged:self.scrubSlider];
        [self clearAction];
        [self trashData];
    } else if (action == ContentActionSave) {
        /*if ([sender isKindOfClass:TelestrationPlaybackViewController.class]) {
            NSLog(@"Filename to export: %@", self.sessionAudioFileName);
            NSError *error = nil;
            [self.controller store:&error];
            if (error == nil) {
                TelestrationSaveViewController *vc = [[TelestrationSaveViewController alloc] initWithSession:self.controller.session delegate:self];
                [self.navigationController pushViewController:vc animated:NO];
            } else {
                NSLog(@"Error storing telestration data: %@", error.userInfo);
                [[[UIAlertView alloc] initWithTitle:@"Can't save session." message:@"There was a problem saving this session. Please try again." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
            }
        } else if ([sender isKindOfClass:TelestrationSaveViewController.class]) {*/
        NSLog(@"Filename to export: %@", self.sessionAudioFileName);
        NSError *error = nil;
        [self.controller store:&error];
        if (error == nil) {
            [self showBackgroundOperationIndicator:@"Saving session..."];
            [MediaService.threadInstance findClipWithIdentity:self.controller.media.identity callback:^(NSError *error, Clip *clip) {
                if (error == nil) {
                    Session *session = [Session createSessionWithClip:clip inContext:clip.managedObjectContext];
                    [self.controller.media updateSession:session];
                    [MediaService.threadInstance saveChanges:^(NSError *error) {
                        self.backgroundOperationErrorCallback(error);
                        if (error == nil) {
                            [self popWithSave];
                        }
                    }];
                } else {
                    self.backgroundOperationErrorCallback(error);
                }
            }];
        } else {
            NSLog(@"Error storing telestration data: %@", error.userInfo);
            [[[UIAlertView alloc] initWithTitle:@"Can't save session." message:@"There was a problem saving this session. Please try again." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
        }
        /*
            // perform save for asset
            [self showBackgroundOperationIndicator:@"Saving telestration"];
            // save changes
            [self.mediaService saveChanges:^(NSError *error) {
                self.backgroundOperationErrorCallback(error);
                if (error == nil) {
                    [self popWithSave];
                }
            }];
        //}*/
    }
}

#pragma mark - Application Events

- (void)applicationWillResignActiveAction
{
    [self stopRecording:NO];
    [super applicationWillResignActiveAction];
}

#pragma mark - Ctor

- (void)setupWithDelegate:(id<ContentActionDelegate>)delegate error:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.ErrorErrorPointerIsNilOrInvalidText);
    *error = nil;
    // ivars
    _delegate = delegate;
    // init recorder & player
    theRecorder = [[TelestrationRecordingController alloc] initWithAudioFileName:self.controller.media.audioFileName error:error];
    if (*error) {
        *error = [NSError errorWithError:*error text:@"Error initializing audio recorder"];
    } else if (![self initializePlayer:error]) {
        *error = [NSError errorWithError:*error text:@"Error initializing video player"];
    }
}

- (id)initWithClip:(Clip *)clip delegate:(id<ContentActionDelegate>)delegate error:(NSError **)error
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        VstrationMediaModel *media = [[VstrationMediaModel alloc] initWithClip:clip];
        if (![self.controller load:media error:error]) {
            *error = [NSError errorWithError:*error text:@"Error loading selected clip"];
        } else {
            [self setupWithDelegate:delegate error:error];
        }
    }
    return self;
}

- (id)initWithSession:(Session *)session delegate:(id<ContentActionDelegate>)delegate error:(NSError **)error
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        VstrationMediaModel *media = [[VstrationMediaModel alloc] initWithSession:session];
        if (![self.controller load:media error:error]) {
            *error = [NSError errorWithError:*error text:@"Error loading selected session"];
        } else {
            [self setupWithDelegate:delegate error:error];
        }
    }
    return self;
}

#pragma mark - View lifecycle

- (void)unhideViews1
{
    //TODO: check this
    self.messageView.hidden = YES;
    [self.messageView removeFromSuperview];
    self.toolsView.hidden = NO;
    self.playbackView.hidden = NO;
    self.recordStartButton.hidden = NO;
    self.recordStopButton.hidden = YES;
    self.scrubSlider.hidden = NO;
    NSLog(@"Player size: %f, %f", self.player.currentItem.presentationSize.width, self.player.currentItem.presentationSize.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // navigation bar
    self.navigationBarView.hidden = YES;
    // views
    [self unhideViews1];
    // color picker & default color
    if (self.colorPicker.superview == nil) {
        self.colorPicker.frame = CGRectMake(self.colorButton.frame.origin.x, self.colorButton.frame.origin.y, self.colorPicker.frame.size.width, self.colorPicker.frame.size.height);
        [self.view addSubview:self.colorPicker];
    }
    for (UIView *view in self.colorPicker.subviews) {
        if ([view isKindOfClass:UIButton.class]) {
            [self selectColorAction:(UIButton *)view];
            break;
        }
    }
    // shape picker & default shape
    if (self.shapePicker.superview == nil) {
        self.shapePicker.frame = CGRectMake(self.shapeButton.frame.origin.x, self.shapeButton.frame.origin.y, self.shapePicker.frame.size.width, self.shapePicker.frame.size.height);
        [self.view addSubview:self.shapePicker];
    }
    for (UIView *view in self.shapePicker.subviews) {
        if ([view isKindOfClass:UIButton.class]) {
            [self selectShapeAction:(UIButton *)view];
            break;
        }
    }
    // this needs to happen here to get the scrub slider set up right.
    self.scrubSlider.maximumValue = self.controller.media.duration.floatValue;
    theFrameChanged = NO;
    // set player
    [self.playbackView setPlayer:self.player];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.showAndHideBlankViewExecuting)
        return;
    // Super
    [super viewWillAppear:animated];
    // Recording
    [self stopRecording:NO];
    // Status Bar
    UIApplication.sharedApplication.statusBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.showAndHideBlankViewExecuting)
        return;
    [super viewDidAppear:animated];
    [self showAndHideBlankView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.showAndHideBlankViewExecuting)
        return;
    // Status Bar
    UIApplication.sharedApplication.statusBarHidden = NO;
    // Recording
    [self stopRecording:NO];
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setMessageView:nil];
    [self setToolsView:nil];
    [self setTrashButton:nil];
    [self setColorButton:nil];
    [self setColorPicker:nil];
    [self setShapeButton:nil];
    [self setShapePicker:nil];
    [self setRecordStartButton:nil];
    [self setRecordStopButton:nil];
    [self setRecordCounterLabel:nil];
    [self setRecordIndicatorView:nil];
    [self setTimelineView:nil];
    [self setTimelineShowButton:nil];
    // Super
    [super viewDidUnload];
}

@end

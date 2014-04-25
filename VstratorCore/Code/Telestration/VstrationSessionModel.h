//
//  VstrationSessionModel.h
//  VstratorApp
//
//  Created by Mac on 22.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Action, Clip, Session, VstrationClipModel;

@interface VstrationSessionModel : NSObject

@property (nonatomic) BOOL isSideBySide;

@property (nonatomic, copy) NSString * actionName;
@property (nonatomic, copy) NSNumber * audioFileDuration;
@property (nonatomic, copy) NSString * audioFileName;
@property (nonatomic, readonly) NSURL * audioFileURL;
@property (nonatomic, copy) NSString * identity;
@property (nonatomic, copy) NSString * sportName;
@property (nonatomic, strong) NSData * telestrationData;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * note;
@property (nonatomic, copy) NSString * url;
@property (nonatomic, copy) NSString * url2;

@property (nonatomic, strong) VstrationClipModel * originalClip;
@property (nonatomic, strong) VstrationClipModel * originalClip2;
@property (nonatomic, readonly, strong) NSArray * originalClipsIdentities;

- (id)initWithClip:(Clip *)clip;
- (id)initWithClip:(Clip *)clip clip2:(Clip *)clip2;
- (id)initWithModel:(VstrationSessionModel *)model;
- (id)initWithSession:(Session *)session;
- (void)updateSession:(Session *)session withAction:(Action *)action;
- (id)copy;

@end

@interface VstrationSessionModel (Playback)

- (NSURL *)playbackURL;
- (NSURL *)playbackURL2;

@end

@interface VstrationClipModel : NSObject

@property (nonatomic, copy) NSNumber * duration;
@property (nonatomic, copy) NSNumber * height;
@property (nonatomic, copy) NSString * identity;
@property (nonatomic, copy) NSString * url;
@property (nonatomic, copy) NSNumber * width;
@property (nonatomic, readonly) NSString* playbackImagesFolder;
@property (nonatomic, copy) NSNumber *frameRate;

- (id)initWithClip:(Clip *)clip;
- (id)initWithModel:(VstrationClipModel *)model;
- (id)copy;

@end

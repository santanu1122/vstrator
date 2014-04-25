//
//  VstrationSessionModel.m
//  VstratorApp
//
//  Created by Mac on 22.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "VstrationSessionModel.h"
#import "Action.h"
#import "Clip+Extensions.h"
#import "Media+Extensions.h"
#import "NSString+Extensions.h"
#import "Session+Extensions.h"
#import "Sport.h"
#import "VstratorConstants.h"

@implementation VstrationSessionModel

#pragma mark Properties

-(NSURL *) audioFileURL
{
    //NOTE: the same code exists and MUST exist in Session+Extensions.m
	if ([NSString isNilOrWhitespace:self.audioFileName])
        return nil;
	NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return [NSURL fileURLWithPath:[path stringByAppendingPathComponent:self.audioFileName]];
}

- (NSArray *)originalClipsIdentities
{
    NSMutableArray *rv = [NSMutableArray arrayWithObject:self.originalClip.identity];
    if (self.isSideBySide)
        [rv addObject:self.originalClip2.identity];
    return rv;
}

#pragma mark Business Logic

- (id)initWithClip:(Clip *)clip
{
    return [self initWithClip:clip clip2:nil];
}

- (id)initWithClip:(Clip *)clip clip2:(Clip *)clip2
{
    self = [super init];
    if (self) {
        // title
        self.actionName = clip.action.name;
        self.audioFileName = [[NSProcessInfo processInfo] globallyUniqueString];
        self.sportName = clip.action.sport.name;
        self.title = clip.title;
        self.note = clip.note;
        // clip
        self.originalClip = [[VstrationClipModel alloc] initWithClip:clip];
        self.url = clip.url;
        // clip2
        if (clip2 != nil) {
            self.originalClip2 = [[VstrationClipModel alloc] initWithClip:clip2];
            self.url2 = clip2.url;
        }
        // sessions
        self.isSideBySide = (clip2 != nil);
    }
    return self;
}

- (id)initWithModel:(VstrationSessionModel *)model
{
    self = [super init];
    if (self) {
        self.actionName = model.actionName;
        self.audioFileDuration = model.audioFileDuration;
        self.audioFileName = model.audioFileName;
        self.identity = model.identity;
        self.isSideBySide = model.isSideBySide;
        self.sportName = model.sportName;
        self.telestrationData = model.telestrationData;
        self.title = model.title;
        self.note = model.note;
        self.url = model.url;
        self.url2 = model.url2;
        if (model.originalClip != nil)
            self.originalClip = [[VstrationClipModel alloc] initWithModel:model.originalClip];
        if (model.originalClip2 != nil)
            self.originalClip2 = [[VstrationClipModel alloc] initWithModel:model.originalClip2];
    }
    return self;
}

- (id)initWithSession:(Session *)session
{
    self = [super init];
    if (self) {
        self.actionName = session.action.name;
        self.audioFileDuration = session.audioFileDuration;
        self.audioFileName = session.audioFileName;
        self.identity = session.identity;
        self.isSideBySide = session.isSideBySide;
        self.sportName = session.action.sport.name;
        self.telestrationData = session.telestrationData;
        self.title = session.title;
        self.note = session.note;
        self.url = session.url;
        self.url2 = session.url2;
        if (session.originalClip != nil)
            self.originalClip = [[VstrationClipModel alloc] initWithClip:session.originalClip];
        if (session.originalClip2 != nil)
            self.originalClip2 = [[VstrationClipModel alloc] initWithClip:session.originalClip2];
    }
    return self;
}

- (void)updateSession:(Session *)session withAction:(Action *)action
{
    session.action = action;
    session.audioFileDuration = self.audioFileDuration;
    session.audioFileName = self.audioFileName;
    session.duration = self.audioFileDuration; //self.duration;
    //session.identity = self.identity;
    session.telestrationData = self.telestrationData;
    session.title = self.title;
    session.note = self.note;
    //session.url = self.url;
    //session.url2 = self.url2;
}

- (id)copy
{
    return [[VstrationSessionModel alloc] initWithModel:self];
}

@end

@implementation VstrationSessionModel (Playback)

- (NSURL *)playbackURL
{
    if (self.originalClip == nil)
        return [NSURL URLWithString:self.url];
    if ([Clip existsPlaybackQualityForIdentity:self.originalClip.identity])
        return [NSURL fileURLWithPath:[Clip pathForPlaybackQualityForIdentity:self.originalClip.identity]];
    return [NSURL URLWithString:self.originalClip.url];
}

- (NSURL *)playbackURL2
{
    if (self.originalClip2 == nil)
        return [NSURL URLWithString:self.url2];
    if ([Clip existsPlaybackQualityForIdentity:self.originalClip2.identity])
        return [NSURL fileURLWithPath:[Clip pathForPlaybackQualityForIdentity:self.originalClip2.identity]];
    return [NSURL URLWithString:self.originalClip2.url];
}

@end


#pragma mark - VstrationClipModel

@implementation VstrationClipModel

- (id)initWithClip:(Clip *)clip
{
    self = [super init];
    if (self) {
        self.duration = clip.duration;
        self.height = clip.height;
        self.identity = clip.identity;
        self.url = clip.url;
        self.width = clip.width;
        _playbackImagesFolder = clip.playbackImagesFolder;
        self.frameRate = clip.frameRate;
    }
    return self;
}

- (id)initWithModel:(VstrationClipModel *)model
{
    self = [super init];
    if (self) {
        self.duration = model.duration;
        self.height = model.height;
        self.identity = model.identity;
        self.url = model.url;
        self.width = model.width;
        _playbackImagesFolder = model.playbackImagesFolder;
        self.frameRate = model.frameRate;
    }
    return self;
}

- (id)copy
{
    return [[VstrationClipModel alloc] initWithModel:self];
}

@end

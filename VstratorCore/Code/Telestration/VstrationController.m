//
//  VstrationController.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "VstrationController.h"
#import "FrameStackModel.h"
#import "TelestrationModel.h"
#import "VstrationSessionModel.h"
#import "VstratorExtensions.h"

@implementation VstrationController

#pragma mark - Properties

- (void)setTelestrations:(TelestrationModel *)telestrations
{
    _telestrations = telestrations;
}

- (void)setFrames:(FrameStackModel *)frames
{
    _frames = frames;
}

- (void)setModel:(VstrationSessionModel *)model
{
    _model = model;
}

#pragma mark - Ctor

- (id)init 
{
    self = [super init];
    if (self) {
        self.telestrations = [[TelestrationModel alloc] init];
        self.frames = [[FrameStackModel alloc] init];
    }
    return self;
}

- (id)initWithController:(VstrationController *)controller
{
    self = [super init];
    if (self) {
        self.model = [controller.model copy];
        self.frames = [controller.frames copy];
        self.telestrations = [controller.telestrations copy];
    }
    return self;
}

- (id)copy
{
    return [[VstrationController alloc] initWithController:self];
}

#pragma mark - Business Logic

- (BOOL)load:(VstrationSessionModel *)model error:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // clear
	[self clear];
    // process
	self.model = model;
	if (self.model.telestrationData) {
		NSDictionary *data = [NSPropertyListSerialization propertyListWithData:self.model.telestrationData
																	   options:NSPropertyListImmutable
																		format:nil
																		 error:error];
		if (*error == nil) {
			[self.frames load:data[@"frames"]];
			[self.telestrations load:data[@"markup"]];
		}
	}
    return !*error;
}

- (BOOL)storeWithSize:(CGSize)superviewSize error:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    NSArray *frameList = [self.frames createExport];
    NSArray *drawings = [self.telestrations createExportWithSize:superviewSize];
    NSDictionary *data = @{@"frames": frameList, @"markup": drawings};
	self.model.telestrationData = [NSPropertyListSerialization dataWithPropertyList:data format:NSPropertyListXMLFormat_v1_0 options:0 error:error];
    return !*error;
}

- (void)clear
{
    [self.telestrations clear];
    [self.frames clear];
}

@end

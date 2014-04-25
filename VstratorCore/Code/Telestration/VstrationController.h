//
//  VstrationController.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FrameStackModel, TelestrationModel, VstrationSessionModel;

@interface VstrationController : NSObject

@property (nonatomic, strong, readonly) TelestrationModel *telestrations;
@property (nonatomic, strong, readonly) FrameStackModel *frames;
@property (nonatomic, strong, readonly) VstrationSessionModel *model;

- (id)init;
- (id)initWithController:(VstrationController *)controller;
- (id)copy;

- (void)clear;
- (BOOL)load:(VstrationSessionModel *)model error:(NSError **)error;
- (BOOL)storeWithSize:(CGSize)superviewSize error:(NSError **)error;


@end

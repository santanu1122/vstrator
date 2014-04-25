//
//  TelestrationEditorViewController.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@class Clip, Session;
@protocol TelestrationEditorViewControllerDelegate;


@interface TelestrationEditorViewController : BaseViewController

@property (nonatomic, weak, readonly) id<TelestrationEditorViewControllerDelegate> delegate;

- (id)initWithClip:(Clip *)clip delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error;
//- (id)initWithSession:(Session *)session delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error;

@end


@protocol TelestrationEditorViewControllerDelegate <NSObject>

@optional
- (void)telestrationEditorViewControllerDidCancel:(TelestrationEditorViewController *)sender;
- (void)telestrationEditorViewControllerDidSave:(TelestrationEditorViewController *)sender session:(Session *)session;

@end

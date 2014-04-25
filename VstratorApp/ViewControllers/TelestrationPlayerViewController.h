//
//  TelestrationPlayerViewController.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class Session, VstrationController;
@protocol TelestrationPlayerViewControllerDelegate;


@interface TelestrationPlayerViewController : BaseViewController

@property (nonatomic, weak, readonly) id<TelestrationPlayerViewControllerDelegate> delegate;

- (id)initForPlayWithSession:(Session *)session autoPlay:(BOOL)autoPlay delegate:(id<TelestrationPlayerViewControllerDelegate>)delegate error:(NSError **)error;
- (id)initForSaveWithController:(VstrationController *)controller delegate:(id<TelestrationPlayerViewControllerDelegate>)delegate error:(NSError **)error;

@end


@protocol TelestrationPlayerViewControllerDelegate <NSObject>

@optional
- (void)telestrationPlayerViewControllerDidCancel:(TelestrationPlayerViewController *)sender;
- (void)telestrationPlayerViewControllerDidSave:(TelestrationPlayerViewController *)sender;

@end

//
//  TelestrationPlayerViewController2.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@class Session, VstrationController;


@interface TelestrationPlayerViewController2 : BaseViewController

@property (nonatomic, unsafe_unretained, readonly) id<BaseResponderDelegate> delegate;

- (id)initForPlayWithSession:(Session *)session autoPlay:(BOOL)autoPlay delegate:(id<BaseResponderDelegate>)delegate error:(NSError **)error;
- (id)initForSaveWithController:(VstrationController *)controller delegate:(id<BaseResponderDelegate>)delegate error:(NSError **)error;

@end

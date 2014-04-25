//
//  SideBySideEditorViewController.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TelestrationEditorViewController.h"

@interface SideBySideEditorViewController : TelestrationEditorViewController

- (id)initWithClip:(Clip *)clip clip2:(Clip *)clip2 delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error;

@end

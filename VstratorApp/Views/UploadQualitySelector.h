//
//  UploadQualitySelectorView
//  VstratorApp
//
//  Created by Admin on 05/12/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Extensions.h"

@interface UploadQualitySelector : NSObject

@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, readonly) UploadQuality selectedUploadQuality;

- (void)show;

@end

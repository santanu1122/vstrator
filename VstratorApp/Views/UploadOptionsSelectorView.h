//
//  UploadOptionsSelectorView.h
//  VstratorApp
//
//  Created by akupr on 14.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Extensions.h"

@interface UploadOptionsSelectorView : UIButton

@property (nonatomic, weak) IBOutlet UIView *controllerView;
@property (nonatomic, readonly) UploadOptions selectedValue;

@end

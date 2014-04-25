//
//  TipLegalView.h
//  VstratorApp
//
//  Created by Mac on 21.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TipViewDelegate.h"

@interface TipLegalView : UIView

@property (nonatomic, weak) IBOutlet id<TipViewDelegate> delegate;

@end

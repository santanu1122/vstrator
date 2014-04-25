//
//  TipViewDelegate.h
//  VstratorApp
//
//  Created by Virtualler on 26.09.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

@protocol TipViewDelegate<NSObject>

@optional
- (void)tipViewDidFinish:(UIView *)sender tipFlag:(BOOL)tipFlag;
- (void)tipView:(UIView *)sender didSelectURL:(NSURL *)url;

@end

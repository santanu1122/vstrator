//
//  TelestrationScrollableBaseView.h
//  VstratorCore
//
//  Created by Admin1 on 23.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TelestrationScrollableBaseView : UIView<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImage *image;
@property (nonatomic) CGAffineTransform viewTransform;

- (void)rotate:(UIRotationGestureRecognizer*)sender;
- (void)appendViewTransform:(CGAffineTransform)viewTransform;

@end

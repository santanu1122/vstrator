//
//  UITextField+Extensions.h
//  VstratorCore
//
//  Created by Virtualler on 20.02.13.
//  Copyright (c) 2013 Futures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Extensions)

- (void)setSidePaddings:(NSInteger)padding;
- (void)setLeftPadding:(NSInteger)padding;
- (void)setRightPadding:(NSInteger)padding;
- (void)setRightPadding:(NSInteger)padding withImage:(UIImage *)image;
- (void)setRightPadding:(NSInteger)padding withImage:(UIImage *)image andImageOffset:(UIOffset)offset;


@end

//
//  UILabel+Extensions.m
//  VstratorCore
//
//  Created by Admin1 on 08.07.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "UILabel+Extensions.h"

@implementation UILabel (Extensions)

-(void)resizeToFitWithMaxHeight:(CGFloat)maxHeight
{
    CGRect newFrame = self.frame;
    newFrame.size.height = [self expectedHeightWithMaxHeight:maxHeight];
    self.frame = newFrame;
}

-(CGFloat)expectedHeightWithMaxHeight:(CGFloat)maxHeight
{
    [self setNumberOfLines:0];
    [self setLineBreakMode:UILineBreakModeWordWrap];
    
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width, maxHeight);
    
    CGSize expectedLabelSize = [[self text] sizeWithFont:[self font]
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:[self lineBreakMode]];
    return expectedLabelSize.height;
}

@end

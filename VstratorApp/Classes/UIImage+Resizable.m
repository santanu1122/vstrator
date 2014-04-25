//
//  UIImage+Resizable.m
//  VstratorApp
//
//  Created by Virtualler on 17.06.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "UIImage+Resizable.h"

@implementation UIImage (Resizable)

+ (UIImage *)resizableImageNamed:(NSString *)name
{
    UIImage *image = [self.class imageNamed:name];
    if (image) {
        if ([name isEqualToString:@"bt-grey-n-black-01"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(21, 5, 22, 5)];
        else if ([name isEqualToString:@"bt-grey-n-black-02"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(21, 5, 22, 5)];
        else if ([name isEqualToString:@"bt-green-n-black-01"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(21, 5, 21, 5)];
        else if ([name isEqualToString:@"bt-dropdown"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(12, 5, 12, 26)];
        else if ([name isEqualToString:@"bt-black-01"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(21, 6, 22, 6)];
        else if ([name isEqualToString:@"bg-white-n-black"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
        else if ([name isEqualToString:@"bg-share-line"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        else if ([name isEqualToString:@"bg-telestration-slider"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(0, 11, 0, 11)];
        else if ([name isEqualToString:@"bt-grey-t01-normal"] || [name isEqualToString:@"bt-grey-t01-sel"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
        else if ([name isEqualToString:@"bg-telestration-bottom"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(45, 3, 0, 0)];
        else if ([name isEqualToString:@"btn_session_tools_h_normal"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
        else if ([name isEqualToString:@"bt-grey-n-black-v35"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(18, 5, 17, 5)];
        else if ([name isEqualToString:@"bt-grey-n-black-h69"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(17, 2, 17, 2)];
        else if ([name isEqualToString:@"bt-home-join-normal"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(44, 8, 44, 8)];
        else if ([name isEqualToString:@"bg-camera-fps"])
            image = [image safeResizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    }
    return image;
}

//
// Prevents generating a lot of error in the log console like this:
//
//    <Error>: CGContextSaveGState: invalid context 0x0
//
-(UIImage*)safeResizableImageWithCapInsets:(UIEdgeInsets)capInsets
{
    if (capInsets.left + capInsets.right >= self.size.width || capInsets.top + capInsets.bottom >= self.size.height) {
        NSLog(@"Warning! Found invalid arguments in [UIImage -resizableImageWithCapInsets:]");
        return self;
    }
    return [self resizableImageWithCapInsets:capInsets];
}

@end

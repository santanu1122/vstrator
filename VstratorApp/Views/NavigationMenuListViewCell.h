//
//  NavigationMenuListViewCell.h
//  VstratorApp
//
//  Created by Admin1 on 03.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseListViewCell.h"

@protocol NavigationMenuListViewCellDelegate;

@interface NavigationMenuListViewCell : BaseListViewCell

@property (weak, nonatomic) id<NavigationMenuListViewCellDelegate> delegate;

+ (CGFloat)rowHeight;

- (void)configureWithTitle:(NSString*)title tag:(int)tag;

@end

@protocol NavigationMenuListViewCellDelegate <NSObject>

- (void)navigationMenuListViewCell:(NavigationMenuListViewCell*)sender didSelectWithTag:(int)tag;

@end
//
//  NavigationMenuListViewCell.m
//  VstratorApp
//
//  Created by Admin1 on 03.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "NavigationMenuListViewCell.h"

@interface NavigationMenuListViewCell()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation NavigationMenuListViewCell

+ (CGFloat)rowHeight
{
    static CGFloat rowHeightValue = -1;
	if (rowHeightValue == -1) {
        NavigationMenuListViewCell *cellInstance = [[NavigationMenuListViewCell alloc] init];
        rowHeightValue = cellInstance.view.bounds.size.height;
	}
    return rowHeightValue;
}

- (void)configureWithTitle:(NSString *)title tag:(int)tag
{
    [self.button setTitle:title forState:UIControlStateNormal];
    self.button.tag = tag;
}

- (IBAction)buttonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(navigationMenuListViewCell:didSelectWithTag:)])
        [self.delegate navigationMenuListViewCell:self didSelectWithTag:self.button.tag];
}

- (void)setupWithDelegate:(id)delegate
{
    [super setupWithDelegate:delegate];
    self.delegate = delegate;
    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
}

@end

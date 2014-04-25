//
//  BaseListViewCell.h
//  VstratorApp
//
//  Created by Lion User on 17/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseListViewCell : UITableViewCell

+ (NSString *)reuseIdentifier;
+ (UITableViewCellStyle)style;
+ (NSString *)nibName;

- (id)initWithDelegate:(id)delegate;
- (void)setupWithDelegate:(id)delegate;
- (id)initWithNibName:(NSString *)nibName delegate:(id)delegate;

@end

//
//  ContentSetListViewCell.h
//  VstratorApp
//
//  Created by Lion User on 27/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentSetListViewTypes.h"
#import "ContentSet.h"
#import "BaseListViewCell.h"

@interface ContentSetListViewCell : BaseListViewCell

+ (CGFloat)rowHeight;

- (void)configureForData:(ContentSet*)contentSet;

@end

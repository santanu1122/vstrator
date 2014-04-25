//
//  TabContentSetView.h
//  VstratorApp
//
//  Created by Admin on 04/04/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentSet.h"

@protocol TabContentSetViewDelegate;

@interface TabContentSetView : UIView

@property (nonatomic, weak) id<TabContentSetViewDelegate> delegate;
@property (nonatomic, copy) NSString *queryString;

@end

@protocol TabContentSetViewDelegate <NSObject>

@required
- (void)tabContentSetView:(TabContentSetView *)sender didSelectContentSet:(ContentSet *)contentSet;

@end

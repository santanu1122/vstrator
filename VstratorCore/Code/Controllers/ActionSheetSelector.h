//
//  ActionSheetSelector.h
//  VstratorApp
//
//  Created by Mac on 14.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ActionSheetSelectorDelegate;



@interface ActionSheetSelector : NSObject

@property (nonatomic, weak) id<ActionSheetSelectorDelegate> delegate;

- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view selectedIndex:(NSInteger)selectedIndex;

@end



@protocol ActionSheetSelectorDelegate <NSObject>

@required
- (NSInteger)actionSheetSelectorItemsCount:(ActionSheetSelector *)sender;
- (NSString *)actionSheetSelector:(ActionSheetSelector *)sender itemTitleAtIndex:(NSInteger)index;

@optional
- (void)actionSheetSelector:(ActionSheetSelector *)sender didSelectItemAtIndex:(NSInteger)index;
- (void)actionSheetSelectorDidCancel:(ActionSheetSelector *)sender;

@end

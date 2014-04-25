//
//  SportActionSelector.h
//  VstratorApp
//
//  Created by Mac on 24.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionSheetSelector.h"

@class Action, Sport;

@protocol SportActionSelectorDelegate;



@interface SportActionSelector : NSObject<ActionSheetSelectorDelegate>

@property (nonatomic, weak) id<SportActionSelectorDelegate> delegate;

- (id)initWithDelegate:(id<SportActionSelectorDelegate>)delegate;

- (void)selectSport:(NSString *)currentSportName;
- (void)selectAction:(NSString *)currentActionName sport:(NSString *)currentSportName;

@end



@protocol SportActionSelectorDelegate <NSObject>

@required
- (UIView *)controllerView;

@optional
- (void)sportActionSelectorLoading:(SportActionSelector *)sender;
- (void)sportActionSelectorLoaded:(SportActionSelector *)sender error:(NSError *)error;
- (void)sportActionSelector:(SportActionSelector *)sender selectedSportName:(NSString *)selectedSportName originalSportName:(NSString *)originalSportName;
- (void)sportActionSelector:(SportActionSelector *)sender selectedSportName:(NSString *)selectedSportName selectedActionName:(NSString *)selectedActionName originalActionName:(NSString *)originalActionName;

@end

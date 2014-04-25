//
//  SportActionSelectorView0.h
//  VstratorApp
//
//  Created by Mac on 02.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportActionSelector0.h"

@interface SportActionSelectorView0 : UIView<SportActionSelectorDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet UIView *controllerView;
@property (nonatomic, copy) NSString *selectedSport;
@property (nonatomic, copy) NSString *selectedAction;
@property (nonatomic, readonly) BOOL selectedSportChanged;
@property (nonatomic, readonly) BOOL selectedActionChanged;

- (void)selectSport;
- (void)selectAction;

@end

//
//  SportActionController.h
//  VstratorApp
//
//  Created by Mac on 16.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SportActionController : NSObject

@property (nonatomic, weak) IBOutlet UIView *controllerView;
@property (nonatomic, weak) IBOutlet UITextField *sportTextField;
@property (nonatomic, weak) IBOutlet UITextField *actionTextField;

@property (nonatomic, copy) NSString *selectedSportName;
@property (nonatomic, copy) NSString *selectedActionName;

- (void)syncViews;

@end

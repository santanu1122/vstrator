//
//  TutorialViewController0.h
//  VstratorApp
//
//  Created by Ryan Latta on 10/20/11.
//  Copyright (c) 2011 Atlantic BT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol TutorialResponderDelegate;



@interface TutorialViewController0 : BaseViewController<UIScrollViewDelegate>

@property (nonatomic, unsafe_unretained) id<TutorialResponderDelegate> delegate;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *tutorialViews;
@property (nonatomic, strong) IBOutlet UIPageControl *pageController;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *lastButton;

- (IBAction)changePage:(id)sender;
- (IBAction)skipAction:(id)sender;
- (IBAction)finishAction:(id)sender;

@end



@protocol TutorialResponderDelegate

@required
- (void)tutorialSkipAction:(id)sender;
- (void)tutorialFinishAction:(id)sender;

@end

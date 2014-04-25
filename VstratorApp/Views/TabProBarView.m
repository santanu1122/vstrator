//
//  TabProBarView.m
//  VstratorApp
//
//  Created by Lion User on 04/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TabProBarView.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface TabProBarView ()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *strokesButton;
@property (weak, nonatomic) IBOutlet UIButton *tutorialsButton;
@property (weak, nonatomic) IBOutlet UIButton *interviewsButton;

@end

@implementation TabProBarView

#pragma mark Business Logic

- (void)setContentType:(TabProViewContentType)contentType
{
    _contentType = contentType;
    [self selectButton];
}

- (void)selectButton
{
    [self setSelectedForButton:self.strokesButton];
    [self setSelectedForButton:self.tutorialsButton];
    [self setSelectedForButton:self.interviewsButton];
}

- (void)setSelectedForButton:(UIButton*)button
{
    button.selected = self.contentType == button.tag;
}

- (void)setTagForButtons
{
    self.strokesButton.tag = TabProViewContentTypeStrokes;
    self.tutorialsButton.tag = TabProViewContentTypeTutorials;
    self.interviewsButton.tag = TabProViewContentTypeInterviews;
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.strokesButton setTitle:VstratorStrings.HomeProUserStrokesButtonTitle forState:UIControlStateNormal];
    [self.tutorialsButton setTitle:VstratorStrings.HomeProUserTutorialsButtonTitle forState:UIControlStateNormal];
    [self.interviewsButton setTitle:VstratorStrings.HomeProUserInterviewsButtonTitle forState:UIControlStateNormal];
}

#pragma mark Actions

- (IBAction)switchViewButtonClicked:(UIButton*)sender {
    self.contentType = sender.tag;
    [self.delegate tabProBarView:self didSwitchToContent:sender.tag];
}

#pragma mark View Lifecycle

- (void)setup
{
    [super setup];
    [self setLocalizableStrings];
    [self setTagForButtons];
    self.contentType = TabProViewContentTypeStrokes;
}

#pragma mark RotatableView

- (void)adjustXibFrame
{
    if (!CGRectIsEmpty(self.bounds))
        self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.view.frame.size.height);
    [super adjustXibFrame];
}

- (void)nilXibOutlets
{
    [super nilXibOutlets];
    self.view = nil;
    self.strokesButton = nil;
    self.tutorialsButton = nil;
    self.interviewsButton = nil;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    [super setOrientation:orientation];
    [self setLocalizableStrings];
    [self setTagForButtons];
    [self selectButton];
}

@end

//
//  TabBarView.m
//  VstratorApp
//
//  Created by Mac on 01.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TabBarView.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface TabBarView()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *proButton;
@property (weak, nonatomic) IBOutlet UIButton *vstrateButton;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *sideBySideButton;

@end

@implementation TabBarView

#pragma mark Properties

- (void)setSelectedAction:(TabBarAction)selectedAction
{
    if (_selectedAction == selectedAction || selectedAction == TabBarActionCapture)
        return;
    _selectedAction = selectedAction;
    [self selectButton];
}

- (void)setSelectedActionAndFire:(TabBarAction)selectedAction
{
    BOOL changesSelection = self.selectedAction != selectedAction;
    // set
    self.selectedAction = selectedAction;
    // delegate
    if ([self.delegate respondsToSelector:@selector(tabBarView:action:changesSelection:)])
        [self.delegate tabBarView:self action:selectedAction changesSelection:changesSelection];
}

#pragma mark Business Logic


- (void)setTagForButtons
{
    self.proButton.tag = TabBarActionPro;
    self.vstrateButton.tag = TabBarActionVstrate;
    self.captureButton.tag = TabBarActionCapture;
    self.sideBySideButton.tag = TabBarActionSideBySide;
}

- (void) selectButton
{
    self.proButton.selected = self.selectedAction == TabBarActionPro;
    self.vstrateButton.selected = self.selectedAction == TabBarActionVstrate;
    self.captureButton.selected = self.selectedAction == TabBarActionCapture;
    self.sideBySideButton.selected = self.selectedAction == TabBarActionSideBySide;
}

#pragma mark Actions

- (IBAction)buttonAction:(id)sender
{
    if ([sender isKindOfClass:UIButton.class])
        [self setSelectedActionAndFire:((UIButton *)sender).tag];
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.proButton setTitle:VstratorStrings.HomeVstrateProContentButtonTitle forState:UIControlStateNormal];
    [self.vstrateButton setTitle:VstratorStrings.HomeVstrateVstrateButtonTitle forState:UIControlStateNormal];
    [self.captureButton setTitle:VstratorStrings.HomeVstrateCaptureClipButtonTitle forState:UIControlStateNormal];
    [self.sideBySideButton setTitle:VstratorStrings.HomeVstrateSideBySideButtonTitle forState:UIControlStateNormal];
}

#pragma mark BaseRotatableView

- (void)setup
{
    [super setup];
    self.backgroundColor = self.view.backgroundColor;
    [self setLocalizableStrings];
    [self setTagForButtons];
    self.selectedAction = TabBarActionNotSet;
}

- (void)adjustXibFrame
{
    if (!CGRectIsEmpty(self.bounds))
        self.view.frame = CGRectMake((self.bounds.size.width - self.view.frame.size.width) / 2.0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [super adjustXibFrame];
}

- (void)nilXibOutlets
{
    [super nilXibOutlets];
    self.view = nil;
    self.proButton = nil;
    self.vstrateButton = nil;
    self.captureButton = nil;
    self.sideBySideButton = nil;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    [super setOrientation:orientation];
    [self setLocalizableStrings];
    [self setTagForButtons];
    [self selectButton];
}

@end

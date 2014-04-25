//
//  TabVstrateBarView.m
//  VstratorApp
//
//  Created by Lion User on 04/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TabVstrateBarView.h"

#import "MediaListViewTypes.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface TabVstrateBarView ()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *myClipsButton;
@property (weak, nonatomic) IBOutlet UIButton *sessionsButton;

@end

@implementation TabVstrateBarView

#pragma mark Properties

- (void)setContentType:(MediaListViewContentType)contentType
{
    _contentType = contentType;
    [self selectButton];
}

#pragma mark Business Logic

- (void)selectButton
{
    [self setSelectedForButton:self.myClipsButton];
    [self setSelectedForButton:self.sessionsButton];
}

- (void)setSelectedForButton:(UIButton*)button
{
    button.selected = self.contentType == button.tag;
}

- (void)setTagForButtons
{
    self.myClipsButton.tag =  MediaListViewContentTypeUserClips;
	self.sessionsButton.tag =  MediaListViewContentTypeUserSessions;
}

- (void)setAlignForButtons
{
    self.myClipsButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.sessionsButton.titleLabel.textAlignment = UITextAlignmentCenter;
}

#pragma mark Actions

- (IBAction)switchViewButtonClicked:(UIButton*)sender
{
    self.contentType = sender.tag;
    if ([self.delegate respondsToSelector:@selector(tabVstrateBarView:didSwitchToContent:)])
        [self.delegate tabVstrateBarView:self didSwitchToContent:sender.tag];
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.myClipsButton setTitle:VstratorStrings.HomeVstrateMyClipsButtonTitle forState:UIControlStateNormal];
    [self.sessionsButton setTitle:VstratorStrings.HomeVstrateVstratedClipsButtonTitle forState:UIControlStateNormal];
}

#pragma mark View Lifecycle

- (void)setup
{
    [super setup];
    [self setLocalizableStrings];
    [self setTagForButtons];
    self.contentType = MediaListViewContentTypeUserClips;
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
    self.myClipsButton = nil;
    self.sessionsButton = nil;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    [super setOrientation:orientation];
    [self setLocalizableStrings];
    [self setTagForButtons];
    if (UIInterfaceOrientationIsPortrait(orientation))
        [self setAlignForButtons];
    [self selectButton];
}

@end

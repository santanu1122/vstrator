//
//  TabUploadQueueBarView.m
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TabUploadQueueBarView.h"
#import "VstratorStrings.h"

@interface TabUploadQueueBarView()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *inProgressButton;
@property (weak, nonatomic) IBOutlet UIButton *completedButton;

@end

@implementation TabUploadQueueBarView

- (void)setContentType:(UploadRequestContentType)contentType
{
    _contentType = contentType;
    [self selectButton];
}

#pragma mark Business Logic

- (void)selectButton
{
    self.allButton.selected = (self.contentType == UploadRequestContentTypeAll);
    self.inProgressButton.selected = (self.contentType == UploadRequestContentTypeInProgress);
    self.completedButton.selected = (self.contentType == UploadRequestContentTypeCompleted);
}

- (void)setTagForButtons
{
    self.allButton.tag = UploadRequestContentTypeAll;
    self.inProgressButton.tag =  UploadRequestContentTypeInProgress;
	self.completedButton.tag =  UploadRequestContentTypeCompleted;
}

#pragma mark Actions

- (IBAction)buttonAction:(UIButton *)sender {
    self.contentType = sender.tag;
    [self.delegate tabUploadQueueBarView:self didSwitchToContentType:sender.tag];
    
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.allButton setTitle:VstratorStrings.UploadQueueAllButtonTitle forState:UIControlStateNormal];
    [self.inProgressButton setTitle:VstratorStrings.UploadQueueInProgressButtonTitle forState:UIControlStateNormal];
    [self.completedButton setTitle:VstratorStrings.UploadQueueCompletedButtonTitle forState:UIControlStateNormal];
}

#pragma mark View Lifecycle

- (void)setup
{
    [super setup];
    [self setLocalizableStrings];
    [self setTagForButtons];
    self.contentType = UploadRequestContentTypeAll;
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
    self.allButton = nil;
    self.inProgressButton = nil;
    self.completedButton = nil;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    [super setOrientation:orientation];
    [self setLocalizableStrings];
    [self setTagForButtons];
    [self selectButton];
}

@end

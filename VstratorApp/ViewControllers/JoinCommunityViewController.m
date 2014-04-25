//
//  JoinCommunityViewController.m
//  VstratorApp
//
//  Created by Admin on 07/09/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "JoinCommunityViewController.h"
#import "UIAlertViewWrapper.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface JoinCommunityViewController ()

@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *reason1Label;
@property (weak, nonatomic) IBOutlet UILabel *reason2Label;
@property (weak, nonatomic) IBOutlet UILabel *reason3Label;

@end

#pragma mark -
@implementation JoinCommunityViewController

@synthesize goButton = _goButton;
@synthesize closeButton = _closeButton;
@synthesize reason1Label = _reason1Label;
@synthesize reason2Label = _reason2Label;
@synthesize reason3Label = _reason3Label;

#pragma mark Actions

- (IBAction)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)goAction:(id)sender
{
    if (![UIApplication.sharedApplication openURL:VstratorConstants.VstratorWwwLearnMoreURL])
        [UIAlertViewWrapper alertString:VstratorStrings.ErrorUnableToOpenSafariWithURL];
}

#pragma mark Business Logic

- (void)setLocalizableStrings
{
    [self.goButton setTitle:VstratorStrings.JoinCommunityGoButtonTitle forState:UIControlStateNormal];
    [self.closeButton setTitle:VstratorStrings.JoinCommunityCloseButtonTitle forState:UIControlStateNormal];
    self.reason1Label.text = VstratorStrings.JoinCommunityReason1;
    self.reason2Label.text = VstratorStrings.JoinCommunityReason2;
    self.reason3Label.text = VstratorStrings.JoinCommunityReason3;
}

#pragma mark Views Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLocalizableStrings];
    self.navigationBarView.hidden = YES;
}

- (void)viewDidUnload {
    [self setGoButton:nil];
    [self setCloseButton:nil];
    [self setReason1Label:nil];
    [self setReason2Label:nil];
    [self setReason3Label:nil];
    [super viewDidUnload];
}

@end

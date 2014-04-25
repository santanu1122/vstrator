//
//  InfoAboutViewController.m
//  VstratorApp
//
//  Created by Mac on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "InfoAboutViewController.h"
#import "WebViewController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface InfoAboutViewController()

@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *appEULALabel;
@property (weak, nonatomic) IBOutlet UIButton *termsOfUseButton;

@end


@implementation InfoAboutViewController

#pragma mark - Actions

- (IBAction)termsOfUseButtonPressed:(id)sender
{
    WebViewController *vc = [[WebViewController alloc] initWithNibName:NSStringFromClass(WebViewController.class) bundle:nil];
    vc.url = VstratorConstants.VstratorWwwTermsOfUseURL;
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    [self.appVersionLabel setText:VstratorStrings.UserInfoVersionOfTheAppLabel];
    [self.appEULALabel setText:[VstratorStrings.UserInfoLicenseOfTheAppLabel stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n\n\n\n"]];
    [self.termsOfUseButton setTitle:VstratorStrings.UserInfoTermsOfUseButtonTitle forState:UIControlStateNormal];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLocalizableStrings];
    [self setResizableImages];
}

- (void)setResizableImages
{
    [self.termsOfUseButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-h69"] forState:UIControlStateNormal];
    [self.termsOfUseButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.appVersionLabel = nil;
    self.appEULALabel = nil;
    self.termsOfUseButton = nil;
    // Super
    [super viewDidUnload];
}

@end

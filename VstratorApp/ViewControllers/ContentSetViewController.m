//
//  ContentSetControllerViewController.m
//  VstratorApp
//
//  Created by Admin on 03/04/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ContentSetViewController.h"
#import "VstratorStrings.h"

@interface ContentSetViewController ()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (nonatomic, strong) ContentSet *contentSet;

@end

@implementation ContentSetViewController

- (void)setContentSet:(ContentSet *)contentSet
{
    _contentSet = contentSet;
}

- (IBAction)downloadAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(contentSetViewController:downloadContentSet:)])
        [self.delegate contentSetViewController:self downloadContentSet:self.contentSet];
}

- (void)refreshLabels
{
    self.titleLabel.text = self.contentSet.name;
    self.descriptionLabel.text = self.contentSet.notes;
}

- (void)setLocalizableStrings
{
    [self.downloadButton setTitle:VstratorStrings.MediaClipSessionViewDownloadButtonTitle forState:UIControlStateNormal];
}

#pragma mark View Lifecycle

- (id)initWithDelegate:(id<ContentSetViewControllerDelegate>)delegate contentSet:(ContentSet *)contentSet
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.contentSet = contentSet;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLocalizableStrings];
    [self refreshLabels];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self rotate:self.interfaceOrientation];
//}

- (void)viewDidUnload
{
    [self setView:nil];
    [self setThumbnailImage:nil];
    [self setTitleLabel:nil];
    [self setDescriptionLabel:nil];
    [self setDownloadButton:nil];
    [super viewDidUnload];
}

#pragma mark Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)rotate:(UIInterfaceOrientation)toInterfaceOrientation
{
    [super rotate:toInterfaceOrientation];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.thumbnailImage.frame = CGRectMake(46, 68, 200, 203);
        self.titleLabel.frame = CGRectMake(192, 68, 274, 21);
        self.descriptionLabel.frame = CGRectMake(192, 90, 274, 79);
        self.downloadButton.frame = CGRectMake(392, 218, 68, 65);
    } else {
        self.thumbnailImage.frame = CGRectMake(80, 47, 200, 203);
        self.titleLabel.frame = CGRectMake(20, 259, 280, 21);
        self.descriptionLabel.frame = CGRectMake(20, 288, 280, 79);
        self.downloadButton.frame = CGRectMake(232, 375, 68, 65);
    }
}

@end

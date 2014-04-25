//
//  TutorialViewController.m
//  VstratorApp
//
//  Created by Ryan Latta on 10/20/11.
//  Copyright (c) 2011 Atlantic BT. All rights reserved.
//

#import "TutorialViewController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface TutorialViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *dontShowFlagButton;
@property (nonatomic, weak) IBOutlet UIPageControl *pageController;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *tutorialViews;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

#pragma mark -

@implementation TutorialViewController

@synthesize dontShowFlagHidden = _dontShowFlagHidden;
@synthesize dontShowFlagValue = _dontShowFlagValue;

- (void)setDontShowFlagValue:(BOOL)dontShowFlagValue
{
    // Value
    _dontShowFlagValue = dontShowFlagValue;
    // Views
    if (self.view) {
        self.dontShowFlagButton.selected = _dontShowFlagValue;
    }
}

- (void)setDontShowFlagHidden:(BOOL)dontShowFlagHidden
{
    // Value
    _dontShowFlagHidden = dontShowFlagHidden;
    // Views
    if (self.view) {
        self.dontShowFlagButton.hidden = _dontShowFlagHidden;
    }
}

- (BOOL)statusBarHidden
{
    return YES;
}

#pragma mark Business Logic

- (IBAction)dontShowFlagAction:(id)sender
{
    self.dontShowFlagValue = !self.dontShowFlagValue;
}

- (IBAction)changePage:(id)sender
{
    self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width * self.pageController.currentPage, 0);
}

- (IBAction)skipAction:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(tutorialViewControllerDidSkip:)])
            [self.delegate tutorialViewControllerDidSkip:self];
    }];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = self.scrollView.contentOffset.x / self.view.frame.size.width;
    self.pageController.currentPage = page;
}

#pragma mark Ctor

- (void)setup
{
    self.dontShowFlagValue = NO;
    self.dontShowFlagHidden = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.dontShowFlagButton setTitle:[@"  " stringByAppendingString:VstratorStrings.UserTutorialDontShowAgainButtonTitle] forState:UIControlStateNormal];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBarView.hidden = YES;
    [self setLocalizableStrings];
    // Add all of the tutorials
    CGFloat x = 0;
    self.pageController.numberOfPages = self.tutorialViews.count;
    for (UIView *tutorialView in self.tutorialViews) 
    {
        [self.scrollView addSubview:tutorialView];
        tutorialView.frame = CGRectMake(x, tutorialView.frame.origin.y, tutorialView.frame.size.width, tutorialView.frame.size.height);
        x += self.view.frame.size.width;
        [self.scrollView setContentSize:CGSizeMake(x, self.view.frame.size.height)];
    }
    [self.pageController setCurrentPage:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGRect frame = self.containerView.frame;
    frame.origin.y = (self.view.frame.size.height - frame.size.height) / 2;
    self.containerView.frame = frame;

    self.dontShowFlagHidden = self.dontShowFlagHidden;
    self.dontShowFlagValue = self.dontShowFlagValue;
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.dontShowFlagButton = nil;
    self.pageController = nil;
    self.scrollView = nil;
    self.tutorialViews = nil;
    // Super
    [super viewDidUnload];
}

@end

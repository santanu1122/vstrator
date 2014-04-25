//
//  TutorialViewController0.m
//  VstratorApp
//
//  Created by Ryan Latta on 10/20/11.
//  Copyright (c) 2011 Atlantic BT. All rights reserved.
//

#import "TutorialViewController0.h"
#import "VstratorCoreClasses.h"

@implementation TutorialViewController0

@synthesize delegate = _delegate;
@synthesize tutorialViews = _tutorialViews;
@synthesize pageController = _pageController;
@synthesize scrollView = _scrollView;
@synthesize lastButton = _lastButton;

#pragma mark - Business Logic

- (void)setNotFirstLaunch
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)changePage:(id)sender
{
}

- (IBAction)skipAction:(id)sender
{
    [self setNotFirstLaunch];
    if (self.delegate == nil) {
        [self.navigationController popViewControllerAnimated:VstratorConstants.ViewControllersNavigationPopAnimated];
    } else {
        [self.delegate tutorialSkipAction:self];
    }
}

- (IBAction)finishAction:(id)sender
{
    [self setNotFirstLaunch];
    if (self.delegate == nil) {
        [self.navigationController popViewControllerAnimated:VstratorConstants.ViewControllersNavigationPopAnimated];
    } else {
        [self.delegate tutorialFinishAction:self];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = self.scrollView.contentOffset.x / self.view.frame.size.width;
    [self.pageController setCurrentPage:page];
}

#pragma mark - KVO

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    int i = 0;
    for (UIImageView *dot in self.pageController.subviews) {
        if([dot isKindOfClass:[UIImageView class]] && i == self.pageController.currentPage)
        {
            //Change the image.
            dot.image = [UIImage imageNamed:@"g_iphone_dot_highlight.png"];
            [dot setNeedsDisplay];
        }
        ++i;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBarView.hidden = YES;

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_gradient.png"]]];

    UIImage *image = [UIImage imageNamed:@"b_green.png"];
    [self.lastButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
    //Add all of the tutorials
    CGFloat x = 0;
    [self.pageController setNumberOfPages:[self.tutorialViews count]];
    for (UIView *tutorialView in self.tutorialViews) 
    {
        [self.scrollView addSubview:tutorialView];
        tutorialView.frame = CGRectMake(x, tutorialView.frame.origin.y, tutorialView.frame.size.width, tutorialView.frame.size.height);
        x += self.view.frame.size.width;
        [self.scrollView setContentSize:CGSizeMake(x, self.view.frame.size.height)];
    }
    [self.pageController setCurrentPage:0];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scrollView = nil;
    self.pageController = nil;
    self.tutorialViews = nil;
    self.lastButton = nil;
    // Super
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.showAndHideBlankViewExecuting)
        return;
    [super viewWillAppear:animated];
    [self.pageController addObserver:self forKeyPath:@"currentPage" options:0 context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.showAndHideBlankViewExecuting)
        return;
    [self.pageController removeObserver:self forKeyPath:@"currentPage"];
    [super viewWillDisappear:animated];
}

@end

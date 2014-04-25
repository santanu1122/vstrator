//
//  TipLegalView.m
//  VstratorApp
//
//  Created by Mac on 21.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TipLegalView.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface TipLegalView()

@property (strong, nonatomic) IBOutlet UIView *legalView;
@property (weak, nonatomic) IBOutlet UILabel *legalTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *legalTextLabel1;
@property (weak, nonatomic) IBOutlet UIButton *legalOkButton;

@end

@implementation TipLegalView

#pragma mark - Properties

@synthesize delegate = _delegate;

@synthesize legalView = _legalView;
@synthesize legalTitleLabel = _legalTitleLabel;
@synthesize legalTextLabel1 = _legalTextLabel1;
@synthesize legalOkButton = _legalOkButton;

#pragma mark - Business Logic

- (IBAction)legalTermsAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tipView:didSelectURL:)])
        [self.delegate tipView:self didSelectURL:VstratorConstants.VstratorWwwTermsOfUseURL];
    else if (![UIApplication.sharedApplication openURL:VstratorConstants.VstratorWwwTermsOfUseURL])
        [UIAlertViewWrapper alertString:VstratorStrings.ErrorUnableToOpenSafariWithURL];
}

- (IBAction)legalAcceptAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tipViewDidFinish:tipFlag:)])
        [self.delegate tipViewDidFinish:self tipFlag:YES];
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    [self.legalTitleLabel setText:VstratorStrings.UserLegalTipTitleLabel];
    [self.legalTextLabel1 setText:VstratorStrings.UserLegalTipTextLabel1];
    [self.legalOkButton setTitle:VstratorStrings.UserLegalTipOkButton forState:UIControlStateNormal];
}

#pragma mark - View Lifecycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    // load NIB
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    NSAssert(self.legalView, VstratorConstants.AssertionNibIsInvalid);
    self.legalView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:self.legalView];
    // localization
    [self setLocalizableStrings];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end

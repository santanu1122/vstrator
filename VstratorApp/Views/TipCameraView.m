//
//  TipCameraView.m
//  VstratorApp
//
//  Created by Mac on 21.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TipCameraView.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface TipCameraView()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *flagButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation TipCameraView

#pragma mark - Properties

@synthesize delegate = _delegate;
@synthesize tipFlag = _tipFlag;

@synthesize view = _view;
@synthesize titleLabel = _titleLabel;
@synthesize textLabel = _textLabel;
@synthesize flagButton = _flagButton;
@synthesize okButton = _okButton;

#pragma mark - Business Logic

- (IBAction)tipFlagAction:(id)sender
{
    if ([sender isKindOfClass:UIButton.class]) {
        _tipFlag = !_tipFlag;
        ((UIButton *)sender).selected = !_tipFlag;
    }
}

- (IBAction)finishAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tipViewDidFinish:tipFlag:)])
        [self.delegate tipViewDidFinish:self tipFlag:self.tipFlag];
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    [self.titleLabel setText:VstratorStrings.UserCaptureTipTitleLabel];
    [self.textLabel setText:VstratorStrings.UserCaptureTipTextLabel];
    [self.flagButton setTitle:[@"  " stringByAppendingString:VstratorStrings.UserCaptureTipDontShowAgainButtonTitle] forState:UIControlStateNormal];
    [self.okButton setTitle:VstratorStrings.UserCaptureTipOkButtonTitle forState:UIControlStateNormal];
}

#pragma mark - View Lifecycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    // load NIB
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.AssertionNibIsInvalid);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:self.view];
    // flag
    self.flagButton.selected = !self.tipFlag;
    // localization
    [self setLocalizableStrings];
}

- (id)initWithDelegate:(id<TipViewDelegate>)delegate tipFlag:(BOOL)tipFlag
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        _tipFlag = tipFlag;
        [self setup];
    }
    return self;
}

@end

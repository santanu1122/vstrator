//
//  SportActionSelectorView0.m
//  VstratorApp
//
//  Created by Mac on 02.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "SportActionSelectorView0.h"
#import "VstratorConstants.h"

@interface SportActionSelectorView0()

@property (strong, nonatomic) SportActionSelector *sportActionSelector;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *sportButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *actionButton;

// SportActionSelector
- (void)sportActionSelectorLoading:(SportActionSelector *)sender;
- (void)sportActionSelectorLoaded:(SportActionSelector *)sender error:(NSError *)error;
- (void)sportActionSelector:(SportActionSelector *)sender selectedSport:(NSString *)selectedSport originalSport:(NSString *)originalSport;
- (void)sportActionSelector:(SportActionSelector *)sender selectedSport:(NSString *)selectedSport selectedAction:(NSString *)selectedAction originalAction:(NSString *)originalAction;

@end

@implementation SportActionSelectorView0

#pragma mark - Properties

@synthesize sportActionSelector = _sportActionSelector;
@synthesize selectedSport = _selectedSport;
@synthesize selectedAction = _selectedAction;
@synthesize selectedSportChanged = _selectedSportChanged;
@synthesize selectedActionChanged = _selectedActionChanged;

@synthesize controllerView = _controllerView;
@synthesize view = _view;
@synthesize sportButton = _sportButton;
@synthesize actionButton = _actionButton;

- (NSString *)selectedSport
{
    return _selectedSport == nil ? nil : [NSString stringWithString:_selectedSport];
}

- (void)setSelectedSport:(NSString *)selectedSport
{
    _selectedSport = selectedSport == nil ? nil : [NSString stringWithString:selectedSport];
    NSString *sportTitle = _selectedSport == nil ? VstratorConstants.SportActionSelectorSelectSportActionName : [NSString stringWithString:_selectedSport];
    [self.sportButton setTitle:sportTitle forState:UIControlStateNormal];
}

- (NSString *)selectedAction
{
    return _selectedAction == nil ? nil : [NSString stringWithString:_selectedAction];
}

- (void)setSelectedAction:(NSString *)selectedAction
{
    _selectedAction = selectedAction == nil ? nil : [NSString stringWithString:selectedAction];
    NSString *actionTitle = _selectedAction == nil ? VstratorConstants.SportActionSelectorSelectActionActionName : [NSString stringWithString:_selectedAction];
    [self.actionButton setTitle:actionTitle forState:UIControlStateNormal];
}

#pragma mark - SportActionSelector

- (void)selectSport
{
    [self.sportActionSelector selectSport:self.selectedSport];
}

- (void)selectAction
{
    [self.sportActionSelector selectAction:self.selectedAction sport:self.selectedSport];
}

- (IBAction)sportButtonAction:(id)sender
{
    [self selectSport];
}

- (IBAction)actionButtonAction:(id)sender
{
    [self selectAction];
}

- (void)sportActionSelectorLoading:(SportActionSelector *)sender
{
    self.sportButton.userInteractionEnabled = NO;
    self.actionButton.userInteractionEnabled = NO;
}

- (void)sportActionSelectorLoaded:(SportActionSelector *)sender error:(NSError *)error
{
    self.sportButton.userInteractionEnabled = YES;
    self.actionButton.userInteractionEnabled = YES;
}

- (void)sportActionSelector:(SportActionSelector *)sender selectedSport:(NSString *)selectedSport originalSport:(NSString *)originalSport
{
    NSString *oldSport = self.selectedSport;
    if (oldSport != nil && [oldSport isEqualToString:selectedSport])
        return;
    self.selectedSport = selectedSport;
    self.selectedAction = nil;
    _selectedSportChanged = YES;
    _selectedActionChanged = YES;
}

- (void)sportActionSelector:(SportActionSelector *)sender selectedSport:(NSString *)selectedSport selectedAction:(NSString *)selectedAction originalAction:(NSString *)originalAction
{
    NSString *oldAction = self.selectedAction;
    if (oldAction != nil && [oldAction isEqualToString:selectedAction])
        return;
    self.selectedAction = selectedAction;
    _selectedActionChanged = YES;
}

#pragma mark - View Lifecycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    // NIB
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.ErrorNibIsInvalidText);
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    // vars
    _selectedSportChanged = NO;
    _selectedActionChanged = NO;
    self.sportActionSelector = [[SportActionSelector alloc] initWithDelegate:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
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

//- (void)dealloc
//{
//    _selectedSport = nil;
//    _selectedAction = nil;
//    _selectedSportChanged = NO;
//    _selectedActionChanged = NO;
//    [self.view removeFromSuperview];
//    self.sportActionSelector = nil;
//    self.sportButton = nil;
//    self.actionButton = nil;
//    self.view = nil;
//}

@end

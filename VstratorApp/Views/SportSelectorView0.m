//
//  SportSelectorView.m
//  VstratorApp
//
//  Created by Mac on 02.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "SportSelectorView0.h"
#import "VstratorConstants.h"

@interface SportSelectorView0()

@property (strong, nonatomic) SportActionSelector *sportActionSelector;

// SportActionSelector
- (void)sportActionSelectorLoading:(SportActionSelector *)sender;
- (void)sportActionSelectorLoaded:(SportActionSelector *)sender error:(NSError *)error;
- (void)sportActionSelector:(SportActionSelector *)sender selectedSport:(NSString *)selectedSport originalSport:(NSString *)originalSport;

@end

@implementation SportSelectorView0

#pragma mark - Properties

@synthesize controllerView = _controllerView;
@synthesize sportActionSelector = _sportActionSelector;
@synthesize selectedSport = _selectedSport;
@synthesize selectedSportChanged = _selectedSportChanged;

- (NSString *)selectedSport
{
    return _selectedSport == nil ? nil : [NSString stringWithString:_selectedSport];
}

- (void)setSelectedSport:(NSString *)selectedSport
{
    _selectedSport = selectedSport == nil ? nil : [NSString stringWithString:selectedSport];
    NSString *sportTitle = _selectedSport == nil ? VstratorConstants.SportActionSelectorPrimarySportActionName : [NSString stringWithString:_selectedSport];
    [self setTitle:sportTitle forState:UIControlStateNormal];
}

- (void)setSelectedSportChanged:(BOOL)selectedSportChanged
{
    _selectedSportChanged = selectedSportChanged;
}

#pragma mark - SportActionSelector

- (void)selectSport
{
    [self.sportActionSelector selectSport:self.selectedSport];
}

- (IBAction)sportButtonAction:(id)sender
{
    [self selectSport];
}

- (void)sportActionSelectorLoading:(SportActionSelector *)sender
{
    self.userInteractionEnabled = NO;
}

- (void)sportActionSelectorLoaded:(SportActionSelector *)sender error:(NSError *)error
{
    self.userInteractionEnabled = YES;
}

- (void)sportActionSelector:(SportActionSelector *)sender selectedSport:(NSString *)selectedSport originalSport:(NSString *)originalSport
{
    NSString *oldSport = self.selectedSport;
    if (oldSport != nil && [oldSport isEqualToString:selectedSport])
        return;
    self.selectedSport = selectedSport;
    self.selectedSportChanged = YES;
}

#pragma mark - View Lifecycle

- (void)setup
{
    self.selectedSportChanged = NO;
    self.sportActionSelector = [[SportActionSelector alloc] initWithDelegate:self];
    [self addTarget:self action:@selector(sportButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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

@end

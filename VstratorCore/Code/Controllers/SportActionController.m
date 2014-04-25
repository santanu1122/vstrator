//
//  SportActionController.m
//  VstratorApp
//
//  Created by Mac on 16.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "SportActionController.h"
#import "SportActionSelector.h"
#import "VstratorStrings.h"

@interface SportActionController() <SportActionSelectorDelegate>
{
    BOOL _loading;
}

@property (nonatomic, strong) IBOutlet UIButton *sportButton;
@property (nonatomic, strong) IBOutlet UIButton *actionButton;
@property (nonatomic, strong) SportActionSelector *selector;

// SportActionSelector
- (void)sportActionSelectorLoading:(SportActionSelector *)sender;
- (void)sportActionSelectorLoaded:(SportActionSelector *)sender error:(NSError *)error;
- (void)sportActionSelector:(SportActionSelector *)sender selectedSportName:(NSString *)selectedSportName originalSportName:(NSString *)originalSportName;
- (void)sportActionSelector:(SportActionSelector *)sender selectedSportName:(NSString *)selectedSportName selectedActionName:(NSString *)selectedActionName originalActionName:(NSString *)originalActionName;

@end

@implementation SportActionController


#pragma mark - Properties

@synthesize controllerView = _controllerView;
@synthesize sportTextField = _sportTextField;
@synthesize actionTextField = _actionTextField;
@synthesize selectedSportName = _selectedSportName;
@synthesize selectedActionName = _selectedActionName;
@synthesize sportButton = _sportButton;
@synthesize actionButton = _actionButton;
@synthesize selector = _selector;

- (void)setSportTextField:(UITextField *)sportTextField
{
    if (_sportTextField == sportTextField)
        return;
    // clear existing text field
    if (self.sportButton != nil) {
        if (self.sportButton.superview != nil)
            [self.sportButton removeFromSuperview];
        self.sportButton = nil;
    }
    // assign
    _sportTextField = sportTextField;
    // setup button & text field
    if (self.sportTextField != nil && !self.sportTextField.hidden) {
        self.sportButton = [self createButtonForTextField:self.sportTextField action:@selector(sportButtonAction:)];
        [self syncSportText];
    }
}

- (void)setActionTextField:(UITextField *)actionTextField
{
    if (_actionTextField == actionTextField)
        return;
    // clear existing text field
    if (self.actionButton != nil) {
        if (self.actionButton.superview != nil)
            [self.actionButton removeFromSuperview];
        self.actionButton = nil;
    }
    // assign
    _actionTextField = actionTextField;
    // setup button & text field
    if (self.actionTextField != nil && !self.actionTextField.hidden) {
        self.actionButton = [self createButtonForTextField:self.actionTextField action:@selector(actionButtonAction:)];
        [self syncActionText];
    }
}

- (void)setSelectedSportName:(NSString *)selectedSportName
{
    _selectedSportName = selectedSportName == nil ? nil : [NSString stringWithString:selectedSportName];
    [self syncSportText];
}

- (void)setSelectedActionName:(NSString *)selectedActionName
{
    _selectedActionName = selectedActionName == nil ? nil : [NSString stringWithString:selectedActionName];
    [self syncActionText];
}

#pragma mark - Business Logic

- (void)syncViews
{
    // just reassign TextFields - properties will handle all other staff
    if (self.sportTextField != nil) {
        UITextField *textField = self.sportTextField;
        self.sportTextField = nil;
        self.sportTextField = textField;
    }
    if (self.actionTextField != nil) {
        UITextField *textField = self.actionTextField;
        self.actionTextField = nil;
        self.actionTextField = textField;
    }
}

- (void)syncSportText
{
    if (self.sportTextField == nil)
        return;
    self.sportTextField.text = (self.selectedSportName == nil ? VstratorStrings.MediaClipSessionEditSelectSportLabel : self.selectedSportName);
}

- (void)syncActionText
{
    if (self.actionTextField == nil)
        return;
    self.actionTextField.text = (self.selectedActionName == nil ? VstratorStrings.MediaClipSessionEditSelectActionLabel : self.selectedActionName);
}

- (void)selectSport
{
    [self.selector selectSport:self.selectedSportName];
}

- (void)selectAction
{
    [self.selector selectAction:self.selectedActionName sport:self.selectedSportName];
}

- (IBAction)sportButtonAction:(id)sender
{
    [self selectSport];
}

- (IBAction)actionButtonAction:(id)sender
{
    [self selectAction];
}

- (UIButton *)createButtonForTextField:(UITextField *)textField action:(SEL)action
{
    if (textField == nil || textField.superview == nil)
        return nil;
    UIButton *button = [[UIButton alloc] initWithFrame:textField.frame];
    button.autoresizingMask = textField.autoresizingMask;
    button.backgroundColor = UIColor.clearColor;
    button.userInteractionEnabled = !_loading;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [textField.superview insertSubview:button belowSubview:textField];
    //TODO: add tracker for frame and so on
    return button;
}

#pragma mark - SportActionSelector

- (void)sportActionSelectorLoading:(SportActionSelector *)sender
{
    _loading = YES;
    self.sportButton.userInteractionEnabled = self.actionButton.userInteractionEnabled = NO;
}

- (void)sportActionSelectorLoaded:(SportActionSelector *)sender error:(NSError *)error
{
    _loading = NO;
    self.sportButton.userInteractionEnabled = self.actionButton.userInteractionEnabled = YES;
}

- (void)sportActionSelector:(SportActionSelector *)sender selectedSportName:(NSString *)selectedSportName originalSportName:(NSString *)originalSportName
{
    NSString *oldSportName = self.selectedSportName;
    if (oldSportName != nil && [oldSportName isEqualToString:selectedSportName])
        return;
    self.selectedSportName = selectedSportName;
    self.selectedActionName = nil;
}

- (void)sportActionSelector:(SportActionSelector *)sender selectedSportName:(NSString *)selectedSportName selectedActionName:(NSString *)selectedActionName originalActionName:(NSString *)originalActionName
{
    NSString *oldActionName = self.selectedActionName;
    if (oldActionName != nil && [oldActionName isEqualToString:selectedActionName])
        return;
    self.selectedActionName = selectedActionName;
}

#pragma mark - View Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        self.selector = [[SportActionSelector alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    self.sportTextField = nil;
    self.actionTextField = nil;
}

@end

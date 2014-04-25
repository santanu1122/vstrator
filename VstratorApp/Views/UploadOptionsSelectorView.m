//
//  UploadOptionsSelectorView.m
//  VstratorApp
//
//  Created by akupr on 14.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "UploadOptionsSelectorView.h"
#import "AccountController2.h"
#import "ActionSheetSelector.h"
#import "VstratorStrings.h"

@interface UploadOptionsSelectorView() <ActionSheetSelectorDelegate>

@property (nonatomic, strong) ActionSheetSelector *actionSheetSelector;
@property (nonatomic, strong) NSDictionary *optionsList;

@end

@implementation UploadOptionsSelectorView

#pragma mark Business Logic

- (NSInteger)indexByValue:(UploadOptions)value
{
    return (value == UploadOnWWAN) ? 1 : 0;
}

- (UploadOptions)valueByIndex:(NSInteger)index
{
    return (index == 1) ? UploadOnWWAN : UploadOnlyOnWiFi;
}

- (void)selectValue
{
    [self.actionSheetSelector showInView:self.controllerView selectedIndex:[self indexByValue:self.selectedValue]];
}

#pragma mark - ActionSheetSelectorDelegate

- (NSInteger)actionSheetSelectorItemsCount:(ActionSheetSelector *)sender
{
    return self.optionsList.count;
}

- (NSString *)actionSheetSelector:(ActionSheetSelector *)sender itemTitleAtIndex:(NSInteger)index
{
    UploadOptions value = [self valueByIndex:index];
    return self.optionsList.count <= index ? @"" : self.optionsList[@(value)];
}

- (void)actionSheetSelector:(ActionSheetSelector *)sender didSelectItemAtIndex:(NSInteger)index
{
    UploadOptions value = [self valueByIndex:index];
    if (_selectedValue != value) {
        _selectedValue = value;
        [AccountController2.sharedInstance updateUserLocally:^(NSError *error, AccountInfo *accountInfo) {
            accountInfo.uploadOptions = value;
        } andSaveWithCallback:^(NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:VAUploadOptionsChangedNotification object:self];
            }
        }];
    }
}

#pragma mark View Lifecycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    self.optionsList = @{ @(UploadOnlyOnWiFi): @"Upload only on WiFi",
                          @(UploadOnWWAN): @"Allow upload over WWAN" };

    _selectedValue = AccountController2.sharedInstance.userAccount.uploadOptions;
    
    self.actionSheetSelector = [[ActionSheetSelector alloc] init];
    self.actionSheetSelector.delegate = self;
    [self addTarget:self action:@selector(selectValue) forControlEvents:UIControlEventTouchUpInside];
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

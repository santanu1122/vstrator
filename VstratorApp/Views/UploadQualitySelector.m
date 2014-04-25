//
//  UploadQualitySelectorView
//  VstratorApp
//
//  Created by Admin on 05/12/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountController2.h"
#import "ActionSheetSelector.h"
#import "VstratorStrings.h"
#import "UploadQualitySelector.h"

@interface UploadQualitySelector() <ActionSheetSelectorDelegate>

@property (nonatomic, strong) ActionSheetSelector *actionSheetSelector;
@property (nonatomic, strong) NSDictionary *qualityList;

@end

@implementation UploadQualitySelector

#pragma mark UploadQualitySelectorView

- (ActionSheetSelector *)actionSheetSelector
{
    if (!_actionSheetSelector) {
        _actionSheetSelector = [[ActionSheetSelector alloc] init];
        _actionSheetSelector.delegate = self;
    }
    return _actionSheetSelector;
}

- (NSDictionary *)qualityList
{
    if (!_qualityList) {
        _qualityList = @{ @(UploadQualityHigh): VstratorStrings.UploadQualityHighName,
                          @(UploadQualityLow): VstratorStrings.UploadQualityLowName };
    }
    return _qualityList;
}

- (void)show
{
    [self.actionSheetSelector showInView:self.parentView selectedIndex:[self indexByUploadQuality:self.selectedUploadQuality]];
}

- (NSInteger)indexByUploadQuality:(UploadQuality)uploadQuality
{
    return (uploadQuality == UploadQualityLow) ? 1 : 0;
}

#pragma mark ActionSheetSelectorDelegate

- (NSInteger)actionSheetSelectorItemsCount:(ActionSheetSelector *)sender
{
    return self.qualityList.count;
}

- (NSString *)actionSheetSelector:(ActionSheetSelector *)sender itemTitleAtIndex:(NSInteger)index
{
    UploadQuality uploadQuality = [self uploadQualityByIndex:index];
    return self.qualityList.count <= index ? @"" : self.qualityList[@(uploadQuality)];
}

- (void)actionSheetSelector:(ActionSheetSelector *)sender didSelectItemAtIndex:(NSInteger)index
{
    UploadQuality uploadQuality = [self uploadQualityByIndex:index];
    if (_selectedUploadQuality != uploadQuality) {
        _selectedUploadQuality = uploadQuality;
        [AccountController2.sharedInstance updateUserLocally:^(NSError *error, AccountInfo *accountInfo) {
            accountInfo.uploadQuality = uploadQuality;
        } andSaveWithCallback:nil];
    }
}

- (UploadQuality)uploadQualityByIndex:(NSInteger)index
{
    return (index == 1) ? UploadQualityLow : UploadQualityHigh;
}

#pragma mark Init

- (void)setup
{
    _selectedUploadQuality = AccountController2.sharedInstance.userAccount.uploadQuality;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

@end

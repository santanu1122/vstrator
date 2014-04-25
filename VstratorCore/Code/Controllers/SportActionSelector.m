//
//  SportActionSelector.m
//  VstratorApp
//
//  Created by Mac on 24.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "SportActionSelector.h"
#import "MediaService.h"
#import "VstratorExtensions.h"

#import <UIKit/UIKit.h>

@interface SportActionSelector()

@property (nonatomic, strong, readonly) ActionSheetSelector *selector;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) NSString *originalSportName;
@property (nonatomic, strong) NSString *originalActionName;
@property (nonatomic) BOOL selectingSports;

@end

@implementation SportActionSelector

#pragma mark - Static Fields

@synthesize delegate = _delegate;
@synthesize selector = _selector;
@synthesize items = _items;

@synthesize originalSportName = _originalSportName;
@synthesize originalActionName = _originalActionName;
@synthesize selectingSports = _selectingSports;

- (ActionSheetSelector *)selector
{
	if (_selector == nil) {
        _selector = [[ActionSheetSelector alloc] init];
        _selector.delegate = self;
    }
	return _selector;
}

#pragma mark - Ctor

- (id)initWithDelegate:(id<SportActionSelectorDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self clearSelect:YES];
    }
    return self;
}

#pragma mark - Selectors

- (NSString *)itemNameByRow:(NSInteger)row
{
    if (self.selectingSports)
        return row < 0 || row >= self.items.count ? nil : ((Sport *)(self.items)[row]).name;
    return row < 0 || row >= self.items.count ? nil : ((Action *)(self.items)[row]).name;
}

- (NSInteger)itemRowByName:(NSString *)name
{
    if (name == nil)
        return -1;
    if (self.selectingSports) {
        for (int i = 0; i < self.items.count; i++) {
            Sport *sport = (self.items)[i];
            if ([sport.name isEqualToString:name])
                return i;
        }
    } else {
        for (int i = 0; i < self.items.count; i++) {
            Action *action = (self.items)[i];
            if ([action.name isEqualToString:name])
                return i;
        }
    }
    return -1;
}

#pragma mark - ActionSheetSelector

- (NSInteger)actionSheetSelectorItemsCount:(ActionSheetSelector *)sender
{
    return self.items.count;
}

- (NSString *)actionSheetSelector:(ActionSheetSelector *)sender itemTitleAtIndex:(NSInteger)index
{
    return [self itemNameByRow:index];
}

- (void)actionSheetSelector:(ActionSheetSelector *)sender didSelectItemAtIndex:(NSInteger)index
{
    if (index < 0)
        return;
    if (self.selectingSports) {
        if ([self.delegate respondsToSelector:@selector(sportActionSelector:selectedSportName:originalSportName:)])
            [self.delegate sportActionSelector:self selectedSportName:[self itemNameByRow:index] originalSportName:self.originalSportName];
    } else {
        if ([self.delegate respondsToSelector:@selector(sportActionSelector:selectedSportName:selectedActionName:originalActionName:)])
            [self.delegate sportActionSelector:self selectedSportName:self.originalSportName selectedActionName:[self itemNameByRow:index] originalActionName:self.originalActionName];
    }
}

- (void)showActionSheetSelector
{
    NSInteger row = [self itemRowByName:(self.selectingSports ? self.originalSportName : self.originalActionName)];
    [self.selector showInView:self.delegate.controllerView selectedIndex:row];
}

#pragma mark - Business Logic

- (void)clearSelect:(BOOL)clearViews
{
    self.selectingSports = YES;
    self.originalSportName = nil;
    self.originalActionName = nil;
}

- (void)selectSport:(NSString *)currentSportName
{
    self.selectingSports = YES;
    self.originalSportName = currentSportName;
    self.originalActionName = nil;
    [self loadItemsAndSelect];
}

- (void)selectAction:(NSString *)currentActionName sport:(NSString *)currentSportName
{
    self.selectingSports = NO;
    self.originalSportName = currentSportName;
    self.originalActionName = currentActionName;
    [self loadItemsAndSelect];
}

- (void)loadItemsAndSelect
{
    if ([self.delegate respondsToSelector:@selector(sportActionSelectorLoading:)])
        [self.delegate sportActionSelectorLoading:self];
    self.items = [[NSArray alloc] init];
    if (self.selectingSports) {
        [MediaService.mainThreadInstance selectSports:^(NSError *error, NSArray *result) {
            if (result != nil)
                self.items = [NSArray sortedArrayWithArrayByName:result];
            if ([self.delegate respondsToSelector:@selector(sportActionSelectorLoaded:error:)])
                [self.delegate sportActionSelectorLoaded:self error:error];
            [self showActionSheetSelector];
        }];
    } else {
        [MediaService.mainThreadInstance findSportWithName:self.originalSportName callback:^(NSError *error, Sport *sport) {
            if (!(sport == nil || sport.actions == nil || sport.actions.count <= 0))
                self.items = [NSArray sortedArrayWithArrayByName:sport.actions.allObjects];
            if ([self.delegate respondsToSelector:@selector(sportActionSelectorLoaded:error:)])
                [self.delegate sportActionSelectorLoaded:self error:error];
            [self showActionSheetSelector];
        }];
    }
}

@end

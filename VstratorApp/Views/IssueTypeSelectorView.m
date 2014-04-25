//
//  IssueTypeSelectorView.m
//  VstratorApp
//
//  Created by Mac on 03.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "IssueTypeSelectorView.h"
#import "ActionSheetSelector.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface IssueTypeSelectorView() <ActionSheetSelectorDelegate>

@property (nonatomic, strong) ActionSheetSelector *actionSheetSelector;
@property (nonatomic, strong) NSArray *issueTypes;

@end

@implementation IssueTypeSelectorView

#pragma mark - Properties

- (void)setSelectedIssueTypeKey:(IssueTypeKey)selectedIssueTypeKey
{
    _selectedIssueTypeKey = selectedIssueTypeKey;
}

#pragma mark - Business Logic

- (NSInteger)indexOfIssueTypeKey:(IssueTypeKey)issueTypeKey
{
    for (int i = 0; i < self.issueTypes.count; i++) {
        IssueType *issueType = (self.issueTypes)[i];
        if (issueType.key == issueTypeKey)
            return i;
    }
    return -1;
}

- (IssueTypeKey)issueTypeKeyByIndex:(NSInteger)index
{
    if (index >= 0 && index < self.issueTypes.count) {
        IssueType *issueType = (self.issueTypes)[index];
        return issueType.key;
    }
    return IssueTypeFeedback;
}

- (NSString *)issueTypeNameByIndex:(NSInteger)row emptyValue:(NSString *)emptyValue
{
    return (self.issueTypes == nil || self.issueTypes.count <= row) ? emptyValue : ((IssueType *)(self.issueTypes)[row]).name;
}

- (void)selectIssueType
{
    NSInteger index = [self indexOfIssueTypeKey:self.selectedIssueTypeKey];
    [self.actionSheetSelector showInView:self.controllerView selectedIndex:index];
}

#pragma mark - ActionSheetSelectorDelegate

- (NSInteger)actionSheetSelectorItemsCount:(ActionSheetSelector *)sender
{
    return self.issueTypes.count;
}

- (NSString *)actionSheetSelector:(ActionSheetSelector *)sender itemTitleAtIndex:(NSInteger)index
{
    return [self issueTypeNameByIndex:index emptyValue:@""];
}

- (void)actionSheetSelector:(ActionSheetSelector *)sender didSelectItemAtIndex:(NSInteger)index
{
    self.selectedIssueTypeKey = [self issueTypeKeyByIndex:index];
    NSString *issueTypeName = [self issueTypeNameByIndex:index emptyValue:VstratorStrings.IssueTypeEmpty];
    [self setTitle:issueTypeName forState:UIControlStateNormal];
}

#pragma mark - View Lifecycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    // create source
    IssueType *issueType1 = [[IssueType alloc] initWithKey:IssueTypeFeedback name:VstratorStrings.IssueTypeFeedbackName];
    IssueType *issueType2 = [[IssueType alloc] initWithKey:IssueTypeBugReport name:VstratorStrings.IssueTypeBugReportName];
    IssueType *issueType3 = [[IssueType alloc] initWithKey:IssueTypeSuggestion name:VstratorStrings.IssueTypeSuggestionName];
    self.issueTypes = @[issueType1, issueType2, issueType3];
    // vars
    self.selectedIssueTypeKey = self.sourceIssueTypeKey = IssueTypeFeedback;
    // selector
    self.actionSheetSelector = [[ActionSheetSelector alloc] init];
    self.actionSheetSelector.delegate = self;
    [self addTarget:self action:@selector(selectIssueType) forControlEvents:UIControlEventTouchUpInside];
    // update title
    [self actionSheetSelector:self.actionSheetSelector didSelectItemAtIndex:0];
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

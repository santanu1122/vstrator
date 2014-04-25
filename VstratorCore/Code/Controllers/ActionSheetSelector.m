//
//  ActionSheetSelector.m
//  VstratorApp
//
//  Created by Mac on 14.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ActionSheetSelector.h"
#import "VstratorConstants.h"

@interface ActionSheetSelector() <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *transparentView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *pickerBackgroundView;
@property (nonatomic, strong) UIToolbar *toolbarView;

@end

@implementation ActionSheetSelector

- (void)createOverlayViewWithFrame:(CGRect)frame
{
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.overlayView.backgroundColor = [UIColor clearColor];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)createTransparentViewWithFrame:(CGRect)frame
{
    self.transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.transparentView.backgroundColor = [UIColor blackColor];
    self.transparentView.alpha = 0.75;
    self.transparentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)createPickerViewWithFrame:(CGRect)frame
{
    self.pickerView = [[UIPickerView alloc] init];
    CGRect pickerFrame = self.pickerView.frame;
    self.pickerView.frame = CGRectMake(0, frame.size.height - pickerFrame.size.height, frame.size.width, pickerFrame.size.height);
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)createPickerBackgroundViewWithFrame:(CGRect)frame
{
    self.pickerBackgroundView = [[UIView alloc] initWithFrame:frame];
    self.pickerBackgroundView.backgroundColor = [UIColor whiteColor];
    self.pickerBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)createToolbarViewViewWithFrame:(CGRect)frame
{
    CGFloat toolbarHeight = 44;
    self.toolbarView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, frame.origin.y - toolbarHeight, frame.size.width, toolbarHeight)];
    UIBarButtonItem *barButtonItemCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    UIBarButtonItem *barButtonItemFlexibleSize = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil];
    UIBarButtonItem *barButtonItemDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectAction:)];
    self.toolbarView.items = @[barButtonItemCancel, barButtonItemFlexibleSize, barButtonItemDone];
    self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - Business Logic

- (void)showInView:(UIView *)view
{
    [self showInView:view selectedIndex:0];
}

- (void)showInView:(UIView *)view selectedIndex:(NSInteger)selectedIndex
{
    [self createOverlayViewWithFrame:view.bounds];
    [self createTransparentViewWithFrame:view.bounds];
    [self createPickerViewWithFrame:view.bounds];
    [self createPickerBackgroundViewWithFrame:self.pickerView.frame];
    [self createToolbarViewViewWithFrame:self.pickerView.frame];
   
    [self.overlayView addSubview:self.transparentView];
    [self.overlayView addSubview:self.pickerBackgroundView];
    [self.overlayView addSubview:self.self.pickerView];
    [self.overlayView addSubview:self.toolbarView];
    [view addSubview:self.overlayView];

    if (selectedIndex >= 0) {
        [self.pickerView selectRow:selectedIndex inComponent:0 animated:NO];
    }
}

- (void)removeViews
{
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
    self.transparentView = nil;
    self.pickerView = nil;
    self.pickerBackgroundView = nil;
    self.toolbarView = nil;
}

- (void)cancelAction:(id)sender
{
    [self removeViews];
    if ([self.delegate respondsToSelector:@selector(actionSheetSelectorDidCancel:)])
        [self.delegate actionSheetSelectorDidCancel:self];
}

- (void)selectAction:(id)sender
{
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    [self removeViews];
    if ([self.delegate respondsToSelector:@selector(actionSheetSelector:didSelectItemAtIndex:)])
        [self.delegate actionSheetSelector:self didSelectItemAtIndex:row];
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.delegate actionSheetSelectorItemsCount:self];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.delegate actionSheetSelector:self itemTitleAtIndex:row];
}

@end

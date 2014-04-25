//
//  ContentSetListViewHeader.m
//  VstratorApp
//
//  Created by Admin on 02/04/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ContentSetListViewHeader.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface ContentSetListViewHeader()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ContentSetListViewHeader

#pragma mark View Lifecycle

- (void)localizeStrings
{
    self.titleLabel.text = VstratorStrings.DownloadContentTitleText;
}

- (void)setup
{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.AssertionNibIsInvalid);
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    [self localizeStrings];
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

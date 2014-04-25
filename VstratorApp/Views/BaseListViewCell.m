//
//  BaseListViewCell.m
//  VstratorApp
//
//  Created by Lion User on 17/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "BaseListViewCell.h"
#import "VstratorConstants.h"

@interface BaseListViewCell()

@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation BaseListViewCell

@synthesize view = _view;

+ (NSString *)reuseIdentifier
{
	return NSStringFromClass(self);
}

+ (UITableViewCellStyle)style 
{ 
    return UITableViewCellStyleDefault; 
}

+ (NSString *)nibName
{
    return NSStringFromClass(self);
}

#pragma mark - View Lifecycle

- (void)setupWithDelegate:(id)delegate
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // NIB
    [[NSBundle mainBundle] loadNibNamed:self.class.nibName owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.AssertionNibIsInvalid);
    // views
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.view.frame.size.height);
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setup
{
    [self setupWithDelegate:nil];
}

- (id)init
{
    return [self initWithStyle:self.class.style reuseIdentifier:self.class.reuseIdentifier];
}

- (id)initWithNibName:(NSString *)nibName delegate:(id)delegate
{
    self = [self init];
    if (self) {
        [self setupWithDelegate:delegate];
    }
    return self;
}

- (id)initWithDelegate:(id)delegate
{
    return [self initWithNibName:nil delegate:delegate];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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

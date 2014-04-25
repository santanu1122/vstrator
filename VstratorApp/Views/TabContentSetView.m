//
//  TabContentSetView.m
//  VstratorApp
//
//  Created by Admin on 04/04/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "TabContentSetView.h"
#import "ContentSetListView.h"

@interface TabContentSetView() <ContentSetListViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet ContentSetListView *contentSetListView;

@end

@implementation TabContentSetView

#pragma mark ContentSetListViewDelegate

- (void)contentSetListView:(ContentSetListView *)sender didSelectContentSet:(ContentSet *)contentSet
{
    if ([self.delegate respondsToSelector:@selector(tabContentSetView:didSelectContentSet:)])
        [self.delegate tabContentSetView:self didSelectContentSet:contentSet];
}

#pragma mark View Lifecycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    // NIB
	NSString* nib = NSStringFromClass(self.class);
    [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    self.contentSetListView.delegate = self;
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

//
//  ContentSetListViewCell.m
//  VstratorApp
//
//  Created by Lion User on 27/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ContentSetListViewCell.h"
#import "VstratorConstants.h"

@interface ContentSetListViewCell()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation ContentSetListViewCell

#pragma mark - Properties

+ (CGFloat)rowHeight
{
    static CGFloat rowHeightValue = -1;
	if (rowHeightValue == -1) {
        ContentSetListViewCell *cellInstance = [[self.class alloc] init];
        rowHeightValue = cellInstance.view.bounds.size.height;
	}
    return rowHeightValue;
}

#pragma mark - Cell Logic

- (void)configureForData:(ContentSet *)contentSet
{
    NSAssert(contentSet, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    self.titleLabel.text = contentSet.name;
    self.descriptionLabel.text = contentSet.notes;
}

#pragma mark - View Lifecycle

@end

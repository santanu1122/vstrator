//
//  MediaListViewCell.h
//  VstratorApp
//
//  Created by Mac on 08.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaPlayerDelegate.h"
#import "MediaListViewTypes.h"
#import "BaseListViewCell.h"

@interface MediaListViewCell : BaseListViewCell

+ (CGFloat)rowHeight;

@property (nonatomic, weak) id<MediaListViewCellDelegate> delegate;

- (void)configureForData:(Media*)media
          authorIdentity:(NSString *)authorIdentity
           selectionMode:(BOOL)selectionMode
             contentType:(MediaListViewContentType)contentType
               tableView:(UITableView *)tableView
               indexPath:(NSIndexPath *)indexPath;

- (void)showDeleteButton;
- (void)hideDeleteButton;

@end

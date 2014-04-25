//
//  MediaListView.h
//  VstratorApp
//
//  Created by Mac on 03.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataSelector.h"
#import "MediaListViewTypes.h"
#import "BaseListView.h"

@interface MediaListView : BaseListView<MediaListViewCellDelegate>

@property (nonatomic, weak) id<MediaListViewDelegate> delegate;
@property (nonatomic) BOOL selectionMode;

- (void)setContentType:(MediaListViewContentType)contentType
      andSelectionMode:(BOOL)selectionMode;

- (void)reload;

@end

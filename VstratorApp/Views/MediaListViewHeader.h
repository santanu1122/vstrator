//
//  MediaListViewHeader.h
//  VstratorApp
//
//  Created by Admin on 01/04/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaListViewTypes.h"
#import "RotatableViewProtocol.h"

@interface MediaListViewHeader : UIView<RotatableViewProtocol>

@property (nonatomic, weak) id<MediaListViewHeaderDelegate> delegate;

@end

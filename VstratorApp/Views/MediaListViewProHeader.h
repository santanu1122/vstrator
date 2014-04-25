//
//  MediaListViewProHeader.h
//  VstratorApp
//
//  Created by Lion User on 27/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaListViewTypes.h"
#import "RotatableViewProtocol.h"

@interface MediaListViewProHeader : UIView<RotatableViewProtocol>

@property (nonatomic, weak) id<MediaListViewProHeaderDelegate> delegate;

@end

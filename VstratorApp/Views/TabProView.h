//
//  TabProView.h
//  VstratorApp
//
//  Created by user on 03.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MediaListViewTypes.h"
#import "RotatableViewProtocol.h"
#import "TabBarViewTypes.h"

typedef enum {
    TabProViewContentTypeStrokes,
    TabProViewContentTypeTutorials,
    TabProViewContentTypeInterviews
} TabProViewContentType;

@protocol TabProViewDelegate;

@interface TabProView : UIView

@property (nonatomic, weak) id<TabProViewDelegate> delegate;
@property (nonatomic, copy) NSString *queryString;
@property (nonatomic) TabProViewContentType selectedContentType;

@end


@protocol TabProViewDelegate<NSObject>

@optional
-(void) tabProViewNavigateToContentSetAtion:(TabProView *)sender;
-(void) tabProView:(TabProView *)sender media:(Media *)media action:(MediaAction)action;
-(void) tabProView:(TabProView *)sender didSwitchToContent:(TabProViewContentType)contentType;

@end

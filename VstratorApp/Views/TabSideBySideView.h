//
//  TabSideBySideView.h
//  VstratorApp
//
//  Created by Mac on 27.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Callbacks.h"
#import "MediaListViewTypes.h"
#import "RotatableViewProtocol.h"
#import "TabBarViewTypes.h"


typedef enum {
    TabSideBySideViewContentTypeSelector,
    TabSideBySideViewContentTypeMedia
} TabSideBySideViewContentType;

@protocol TabSideBySideViewDelegate;


@interface TabSideBySideView : UIView<MediaListViewDelegate, TabBarViewItemDelegate, RotatableViewProtocol>

@property (nonatomic, weak) id<TabSideBySideViewDelegate> delegate;
@property (nonatomic, strong) Clip *clip;
@property (nonatomic, strong) Clip *clip2;
@property (nonatomic, copy) NSString *queryString;
@property (nonatomic) TabSideBySideViewContentType selectedContentType;

@end


@protocol TabSideBySideViewDelegate<NSObject>

@required
-(void) tabSideBySideView:(TabSideBySideView *)sender vstrateClip:(Clip *)clip withClip2:(Clip *)clip2;
-(void) tabSideBySideView:(TabSideBySideView *)sender captureClipWithCallback:(GetClipCallback)completionCallback;
@optional
-(void) tabSideBySideView:(TabSideBySideView *)sender didSwitchToContent:(TabSideBySideViewContentType)contentType;

@end

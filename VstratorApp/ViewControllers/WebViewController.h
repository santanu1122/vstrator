//
//  WebViewController.h
//  VstratorApp
//
//  Created by Virtualler on 27.09.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol WebViewControllerProtocol;

@interface WebViewController : BaseViewController

@property (nonatomic, weak) id<WebViewControllerProtocol> delegate;
@property (nonatomic, strong) NSURL *url;

@end

@protocol WebViewControllerProtocol <NSObject>

@optional

- (void)webViewControllerDidClose:(WebViewController *)sender;

@end

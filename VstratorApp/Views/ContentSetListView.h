//
//  ContentSetListView.h
//  VstratorApp
//
//  Created by Lion User on 27/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataSelector.h"
#import "ContentSetListViewTypes.h"
#import "BaseListView.h"

@interface ContentSetListView : BaseListView

@property (nonatomic, weak) id<ContentSetListViewDelegate> delegate;

- (void)reload;

@end

//
//  ContentSetListViewTypes.h
//  VstratorApp
//
//  Created by Lion User on 27/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

@class ContentSet, ContentSetListView;

@protocol ContentSetListViewDelegate<NSObject>

- (void)contentSetListView:(ContentSetListView *)sender
       didSelectContentSet:(ContentSet *)contentSet;

@end

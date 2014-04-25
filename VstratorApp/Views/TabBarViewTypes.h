//
//  TabBarViewTypes.h
//  VstratorApp
//
//  Created by Mac on 27.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#ifndef VstratorApp_TabBarViewTypes_h
#define VstratorApp_TabBarViewTypes_h

typedef enum {
    TabBarActionNotSet,
    TabBarActionPro,
    TabBarActionVstrate,
    TabBarActionCapture,
    TabBarActionSideBySide
} TabBarAction;

@protocol TabBarViewItemDelegate<NSObject>

@property (nonatomic, copy) NSString *queryString;

@end

#endif

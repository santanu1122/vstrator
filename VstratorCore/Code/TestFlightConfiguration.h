//
//  TestFlightConfiguration.h
//  VstratorApp
//
//  Created by Lion User on 29/06/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#if !(defined(DEBUG) || defined(RELEASE_APPSTORE))

#define kVATestFlightActive

#ifdef kVATestFlightActive

#import <TestFlightSDK/TestFlight.h>

// TakeOff: ...OnTarget
#define kVATestFlightTakeOff @"1f6c687e2c72d3d33633ab5203a1d246_MTA0NTcxMjAxMi0wNi0yNyAxMjoxMzowNC41MTEwOTc"
// ...Vstrator
//#define kVATestFlightTakeOff @"3e3e124552a38eebdfba1927f83ea7b8_ODIyMDYyMDEyLTA0LTI3IDEyOjQ4OjQwLjM1NzY4MQ"

// Replace NSLog in all project files
//#define NSLog(__FORMAT__, ...) TFLog(__FORMAT__, ##__VA_ARGS__)
#define NSLog(__FORMAT__, ...)                                                                  \
    do {                                                                                        \
        NSLog(__FORMAT__, ##__VA_ARGS__);                                                       \
        TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);     \
    } while(0)

#endif

#endif
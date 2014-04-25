//
//  TaskManager.h
//  VstratorCore
//
//  Created by akupr on 07.11.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskManager : NSObject

+ (TaskManager *)sharedInstance;

- (void)startPersistentDispatchers;
- (void)stopPersistentDispatchers;

- (void)startTaskDispatchers;
- (void)stopTaskDispatchers;

@end

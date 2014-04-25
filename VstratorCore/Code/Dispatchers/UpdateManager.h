//
//  UpdateManager.h
//  VstratorCore
//
//  Created by akupr on 11.12.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateManager : NSObject

-(void)processUpdates:(Callback0)callback;
-(void)updateSportsAndActions:(ErrorCallback)callback;

@end

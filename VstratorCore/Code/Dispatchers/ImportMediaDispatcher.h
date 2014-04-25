//
//  ImportMediaDispatcher.h
//  VstratorApp
//
//  Created by user on 29.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"

@interface ImportMediaDispatcher : NSObject

-(void)processImportWithCallback:(ErrorCallback)errorCallback;

@end

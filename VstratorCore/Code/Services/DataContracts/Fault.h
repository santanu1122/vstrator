//
//  Fault.h
//  VstratorApp
//
//  Created by akupr on 09.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface Fault : NSObject

@property (nonatomic, copy) NSString* message;

+(RKObjectMapping*) mapping;

@end

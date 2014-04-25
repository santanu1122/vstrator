//
//  Mappable.h
//  VstratorCore
//
//  Created by akupr on 10.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@protocol Mappable <NSObject>

@optional

+(RKObjectMapping*)mapping;
+(RKObjectMapping*)serialization;

@end

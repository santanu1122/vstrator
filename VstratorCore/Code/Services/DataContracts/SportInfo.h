//
//  SportInfo.h
//  VstratorApp
//
//  Created by user on 19.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mappable.h"

@interface SportInfo : NSObject<Mappable>

@property (nonatomic, copy) NSNumber* identity;
@property (nonatomic, copy) NSString* sport;
@property (nonatomic, strong) NSArray* actions;

@end

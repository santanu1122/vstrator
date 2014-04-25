//
//  DescriptorBuilder.h
//  VstratorCore
//
//  Created by akupr on 05.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKResponseDescriptor, RKRequestDescriptor;

@interface DescriptorBuilder : NSObject

@property (nonatomic, readonly) NSArray* responseDescriptors;
@property (nonatomic, readonly) NSArray* requestDescriptors;

-(RKResponseDescriptor*)addResponseDescriptorFromObject:(NSDictionary*)object;
-(RKRequestDescriptor*)addRequestDescriptorFromObject:(NSDictionary*)object;
-(void)parseDescriptorsSettings:(NSDictionary*)settings;

@end

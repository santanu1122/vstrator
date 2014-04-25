//
//  ContentSet+Extensions.h
//  VstratorCore
//
//  Created by akupr on 11.02.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ContentSet.h"

@interface ContentSet (Extensions)

+(ContentSet*)contentSetFromObject:(NSDictionary*)info inContext:(NSManagedObjectContext*)context error:(NSError**)error;
-(void)updateWithObject:(NSDictionary*)info;
-(void)downloadAll;

@end

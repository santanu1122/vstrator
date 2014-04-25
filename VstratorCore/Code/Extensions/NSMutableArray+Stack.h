//
//  NSArray+Stack.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Stack)

-(void) push:(id) object;
-(id) pop;

@end

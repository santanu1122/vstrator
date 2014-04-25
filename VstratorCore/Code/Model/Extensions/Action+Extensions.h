//
//  Action+Extensions.h
//  VstratorApp
//
//  Created by user on 22.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Action.h"

@interface Action (Extensions)

+(Action*)actionWithName:(NSString *)actionName 
         sportName:(NSString *)sportName 
         inContext:(NSManagedObjectContext *)context 
             error:(NSError **)error;

@end

//
//  Action+Extensions.m
//  VstratorApp
//
//  Created by user on 22.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Action+Extensions.h"
#import "Sport+Extensions.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@implementation Action (Extensions)

+(Action*)createActionWithName:(NSString *)actionName
                     sportName:(NSString *)sportName
                     inContext:(NSManagedObjectContext *)context
                         error:(NSError **)error
{
    Action* action = [NSEntityDescription insertNewObjectForEntityForName:@"Action" inManagedObjectContext:context];
    action.name = actionName;
    action.sport = [Sport sportWithName:sportName inContext:context error:error];
	return action;
}

+(Action*)actionWithName:(NSString *)actionName
               sportName:(NSString *)sportName
               inContext:(NSManagedObjectContext *)context
                   error:(NSError **)error
{
	NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Action"];
	request.predicate = [NSPredicate predicateWithFormat:@"name ==[cd] %@ AND sport.name ==[cd] %@", actionName, sportName];
	NSArray* result = [context executeFetchRequest:request error:error];
    if (*error || !result) {
        *error = [NSError errorWithError:*error text:VstratorStrings.ErrorDatabaseSelectText];
        return nil;
    }
    return result.count > 0 ? result.lastObject : [self createActionWithName:actionName sportName:sportName inContext:context error:error];
}

@end

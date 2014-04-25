//
//  Sport+Extensions.m
//  VstratorApp
//
//  Created by user on 22.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Sport+Extensions.h"
#import "NSError+Extensions.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@implementation Sport (Extensions)

+(Sport*)createSportWithName:(NSString *)name
                   inContext:(NSManagedObjectContext *)context
{
    Sport *sport = [NSEntityDescription insertNewObjectForEntityForName:@"Sport" inManagedObjectContext:context];
	sport.name = name;
	return sport;
}

+(Sport*)sportWithName:(NSString *)name
             inContext:(NSManagedObjectContext *)context
                 error:(NSError **)error
{
	NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Sport"];
	request.predicate = [NSPredicate predicateWithFormat:@"name ==[cd] %@", name];
	NSArray* result = [context executeFetchRequest:request error:error];
    if (*error != nil || result == nil) {
        *error = [NSError errorWithError:*error text:VstratorStrings.ErrorDatabaseSelectText];
        return nil;
    }
    return result.count > 0 ? result.lastObject : [self createSportWithName:name inContext:context];
}

@end

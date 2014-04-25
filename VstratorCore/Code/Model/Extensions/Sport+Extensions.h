//
//  Sport+Extensions.h
//  VstratorApp
//
//  Created by user on 22.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Sport.h"

@interface Sport (Extensions)

+(Sport*)sportWithName:(NSString *)name
             inContext:(NSManagedObjectContext *)context
                 error:(NSError **)error;

@end

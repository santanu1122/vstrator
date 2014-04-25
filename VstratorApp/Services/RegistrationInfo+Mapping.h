//
//  RegistrationInfo+Mapping.h
//  VstratorApp
//
//  Created by Mac on 22.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegistrationInfo.h"
#import <RestKit/RestKit.h>

@interface RegistrationInfo (Mapping)

+(RKObjectMapping*) mapping;

@end

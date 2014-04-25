//
//  TelestrationModel.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackModel.h"

@interface TelestrationModel : StackModel

- (id)copy;

- (NSArray *)createExportWithSize:(CGSize)superviewSize;
- (void)load:(NSArray *)telestrations;

@end

//
//  NSFileManager+Extensions.h
//  VstratorCore
//
//  Created by akupr on 12.12.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Extensions)

-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL error:(NSError**)error;

@end

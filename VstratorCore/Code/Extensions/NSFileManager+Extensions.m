//
//  NSFileManager+Extensions.m
//  VstratorCore
//
//  Created by akupr on 12.12.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <sys/xattr.h>
#import "NSFileManager+Extensions.h"

@implementation NSFileManager (Extensions)

-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url error:(NSError**)error
{
    if (![self fileExistsAtPath:[url path]]) return NO;
    
    if ([[UIDevice currentDevice].systemVersion compare:@"5.0.1"] == NSOrderedAscending) {
        // System version < 5.0.1, just do nothing
        return NO;
    }
    if ([[UIDevice currentDevice].systemVersion compare:@"5.1"] == NSOrderedAscending) {
        // System version < 5.1
        const char* filePath = [[url path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        return setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0) == 0;
    }
    // System version >= 5.1
    return [url setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error:error];
}

@end

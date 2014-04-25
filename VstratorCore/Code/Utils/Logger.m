//
//  Logger.m
//  VstratorCore
//
//  Created by Admin on 15/03/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "Logger.h"

#define kVALogFilePrefix @"Log"
#define kVAActiveTimeInterval (60*60*24*1)

@implementation Logger

#pragma mark Interface

+ (void)initLogger
{
#if DEBUG
    return;
#endif
    NSString *folder = [self createlogsFolder];
    if (!folder) return;
    
    [self nsLogToFileInFolder:folder];
    [self removeOldLogsInFolder:folder];
}

+ (NSString*)latestAvailableLogFullFileName
{
    NSString *folder = [self createlogsFolder];
    if (!folder) return nil;
    
    NSError *error;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray *contents = [manager contentsOfDirectoryAtPath:folder error:&error];
    if (error) {
        NSLog(@"Can not get contents of folder '%@'. Error: %@", folder, error);
        return nil;
    }
    
    NSString *latestFileName;
    for (NSString *item in contents) {
        if (![[item pathExtension] isEqualToString:@"log"]) continue;
        if (!latestFileName) {
            latestFileName = item;
            continue;
        }
        if ([latestFileName compare:item] == NSOrderedDescending) continue;
        latestFileName = item;
    }
    
    if (!latestFileName) return nil;
    return [folder stringByAppendingPathComponent:latestFileName];
}

#pragma mark Utils

+ (void)nsLogToFileInFolder:(NSString*)folder
{
    NSString *fullFileName = [folder stringByAppendingPathComponent:[self currentLogFileName]];
    freopen([fullFileName cStringUsingEncoding:NSUTF8StringEncoding], "a", stderr);
}

+ (void)removeOldLogsInFolder:(NSString*)folder
{
    NSError *error;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray *contents = [manager contentsOfDirectoryAtPath:folder error:&error];
    if (error) {
        NSLog(@"Can not get contents of folder '%@'. Error: %@", folder, error);
        return;
    }
    
    NSString *currentName = [self latestLogFileNameToStore];
    for (NSString *item in contents) {
        if (![[item pathExtension] isEqualToString:@"log"] ||
            [currentName compare:item] != NSOrderedDescending) continue;
        [manager removeItemAtPath:[folder stringByAppendingPathComponent:item] error:&error];
        if (error) NSLog(@"Can not remove file '%@'. Error: %@", item, error);
    }
}

+ (NSString*)createlogsFolder
{
    NSError *error;
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *folder = [[cachePathArray lastObject] stringByAppendingPathComponent:@"Logs"];
    NSFileManager* manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"Can not create folder '%@'. Error: %@", folder, error);
        return nil;
    }
    return folder;
}

+ (NSString*)currentLogFileName
{
    return [self logFileNameFromDate:[NSDate date]];
}

+ (NSString*)latestLogFileNameToStore
{
    return [self logFileNameFromDate:[NSDate dateWithTimeIntervalSinceNow:-kVAActiveTimeInterval]];
}

+ (NSString*)logFileNameFromDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@%@.log", kVALogFilePrefix, dateString];
}

@end

//
//  Issue.m
//  VstratorApp
//
//  Created by user on 14.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "Issue.h"
#import "NSString+Extensions.h"
#import "Logger.h"

@implementation Issue

-(id)initWithIssueType:(IssueTypeKey)issueType andDescription:(NSString *)description
{
    self = [self init];
    if (self) {
        self.issueType = issueType;
        self.description = description;
    }
    return self;
}

-(void)setDescription:(NSString *)description
{
    NSParameterAssert(description);
    NSString* version = [[NSBundle bundleForClass:[Issue class]] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    _description = version ? [@[version, description] componentsJoinedByString:@"\n"] : description;
}

-(NSString*)logFile
{
    NSString *fullFileName = [Logger latestAvailableLogFullFileName];
    NSString *logFileContent = [NSString stringWithContentsOfFile:fullFileName encoding:NSUTF8StringEncoding error:nil];
    if (!logFileContent) logFileContent = @"";
    return logFileContent;
}

+(RKObjectMapping *)serialization
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromArray:@[@"description", @"issueType", @"logFile"]];
    return mapping;
}

@end

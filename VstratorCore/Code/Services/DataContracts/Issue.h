//
//  Issue.h
//  VstratorApp
//
//  Created by user on 14.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IssueType.h"
#import "Mappable.h"

@interface Issue : NSObject<Mappable>

@property (nonatomic) IssueTypeKey issueType;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, readonly) NSString* logFile;

- (id)initWithIssueType:(IssueTypeKey)issueType andDescription:(NSString *)description;

@end

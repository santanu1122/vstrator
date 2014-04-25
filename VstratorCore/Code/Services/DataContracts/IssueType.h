//
//  IssueType.h
//  VstratorApp
//
//  Created by Mac on 03.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum IssueTypeKey {
	IssueTypeFeedback,
	IssueTypeBugReport,
	IssueTypeSuggestion
} IssueTypeKey;


@interface IssueType : NSObject

@property (nonatomic) IssueTypeKey key;
@property (nonatomic, copy) NSString *name;

- (id)initWithKey:(IssueTypeKey)key name:(NSString *)name;

@end

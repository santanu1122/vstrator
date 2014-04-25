//
//  NSString+Extensions.h
//  VstratorApp
//
//  Created by Mac on 04.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

+ (BOOL)isNilOrEmpty:(NSString *)string;
+ (BOOL)isNilOrWhitespace:(NSString *)string;
+ (NSString *)stringWithStringOrNil:(NSString *)string;
+ (NSString *)trimmedStringOrNil:(NSString *)string;
+ (NSString *)trimmedStringOrNil:(NSString *)string replaceMultipleSpaces:(BOOL)replaceMultipleSpaces;
+ (NSString *)fromSecons:(int)seconds;

- (NSString *)trim;
- (NSString *)replaceMultipleSpaces;

@end

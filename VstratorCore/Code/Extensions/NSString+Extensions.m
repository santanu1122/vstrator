//
//  NSString+Extensions.m
//  VstratorApp
//
//  Created by Mac on 04.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+ (BOOL)isNilOrEmpty:(NSString *)string
{
    return (string == nil || string.length <= 0);
}

+ (BOOL)isNilOrWhitespace:(NSString *)string
{
    return (string == nil || string.length <= 0 || [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0);
}

+ (NSString *)stringWithStringOrNil:(NSString *)string
{
    return string == nil ? nil : [NSString stringWithString:string];
}

+ (NSString *)trimmedStringOrNil:(NSString *)string
{
    return [self.class trimmedStringOrNil:string replaceMultipleSpaces:NO];
}

+ (NSString *)trimmedStringOrNil:(NSString *)string replaceMultipleSpaces:(BOOL)replaceMultipleSpaces
{
    NSString *str = ([NSString isNilOrWhitespace:string] ? nil : [string trim]);
    return (str != nil && str.length > 1 && replaceMultipleSpaces) ? [str replaceMultipleSpaces] : str;
}

+ (NSString *)fromSecons:(int)seconds
{
    int min = seconds / 60;
    int sec = seconds - min * 60;
    return [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

- (NSString *)trim
{
    return self == nil ? nil : [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)replaceMultipleSpaces
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:nil];
    return [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@" "];
}

@end

//
//  ValidationHelper.m
//  VstratorApp
//
//  Created by Mac on 14.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ValidationHelper.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface ValidationHelper()

+ (void)addValidationError:(NSString *)errorString 
              outputString:(NSString **)outputString;

@end

@implementation ValidationHelper

+ (void)addValidationError:(NSString *)errorString 
              outputString:(NSString **)outputString
{
    if ([NSString isNilOrEmpty:errorString] || outputString == nil)
        return;
    NSString *firstPart = [NSString isNilOrEmpty:*outputString] ? @"" : (*outputString);
    NSString *delim = firstPart.length <= 0 ? @"" : @"\n";
    *outputString = [NSString stringWithFormat:@"%@%@%@", firstPart, delim, errorString];
}

+ (BOOL)validateForEmptyValue:(NSString *)value 
                  errorString:(NSString *)errorString
                 outputString:(NSString **)outputString
{
    if (![NSString isNilOrEmpty:value])
        return YES;
    [self.class addValidationError:errorString outputString:outputString];
    return NO;
}

+ (BOOL)validateForEmptyTrimmedValue:(NSString *)value
                         errorString:(NSString *)errorString
                        outputString:(NSString **)outputString
{
    value = value == nil ? @"" : [value trim];
    if (value.length > 0)
        return YES;
    [self.class addValidationError:errorString outputString:outputString];
    return NO;
}

+ (BOOL)validateForLength:(NSString *)value
                minLength:(NSInteger)minLength
                maxLength:(NSInteger)maxLength
              errorString:(NSString *)errorString
             outputString:(NSString **)outputString
{
    value = value == nil ? @"" : [value trim];
    if ((minLength <= 0 || value.length >= minLength) && (maxLength <= 0 || value.length <= maxLength))
        return YES;
    [self.class addValidationError:errorString outputString:outputString];
    return NO;
}

+ (BOOL)validateForTrimmedEquality:(NSString *)value
                       errorString:(NSString *)errorString
                      outputString:(NSString **)outputString
{
    value = value == nil ? @"" : value;
    if ([value isEqualToString:[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]])
        return YES;
    [self.class addValidationError:errorString outputString:outputString];
    return NO;
}

+ (BOOL)validateForNameContent:(NSString *)value 
                   errorString:(NSString *)errorString
                  outputString:(NSString **)outputString
{
    value = value == nil ? @"" : value;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\w[\\w\\d]*([\\s\\-'][\\w\\d]+)*$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:value options:0 range:NSMakeRange(0, [value length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0)))
        return YES;
    [self.class addValidationError:errorString outputString:outputString];
    return NO;
}

+ (BOOL)validateForEmailContent:(NSString *)value 
                    errorString:(NSString *)errorString
                   outputString:(NSString **)outputString
{
    value = value == nil ? @"" : value;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[\\w\\d._%+-]+@[\\w\\d0-9.-]+\\.[\\w\\d]{2,}$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:value options:0 range:NSMakeRange(0, [value length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0)))
        return YES;
    [self.class addValidationError:errorString outputString:outputString];
    return NO;
}

+ (BOOL)validateFirstName:(NSString *)value 
             outputString:(NSString **)outputString
{
    return [self.class validateForEmptyTrimmedValue:value errorString:VstratorStrings.ErrorFirstNameIsEmptyText outputString:outputString] && [self.class validateForTrimmedEquality:value errorString:VstratorStrings.ErrorFirstNameBeginsOrEndsWithSpacesText outputString:outputString] && [self.class validateForLength:value minLength:1 maxLength:VstratorConstants.MaxNameLength errorString:VstratorStrings.ErrorFirstNameHasInvalidLengthText outputString:outputString] && [self.class validateForNameContent:value errorString:VstratorStrings.ErrorFirstNameIsInvalidText outputString:outputString];
}

+ (BOOL)validateSecondName:(NSString *)value 
              outputString:(NSString **)outputString
{
    return [self.class validateForEmptyTrimmedValue:value errorString:VstratorStrings.ErrorSecondNameIsEmptyText outputString:outputString] && [self.class validateForTrimmedEquality:value errorString:VstratorStrings.ErrorSecondNameBeginsOrEndsWithSpacesText outputString:outputString] && [self.class validateForLength:value minLength:1 maxLength:VstratorConstants.MaxNameLength errorString:VstratorStrings.ErrorSecondNameHasInvalidLengthText outputString:outputString] && [self.class validateForNameContent:value errorString:VstratorStrings.ErrorSecondNameIsInvalidText outputString:outputString];
}

+ (BOOL)validateTitle:(NSString *)value 
         outputString:(NSString **)outputString
{
    return [self.class validateForEmptyTrimmedValue:value errorString:VstratorStrings.ErrorTitleIsEmptyText outputString:outputString] && [self.class validateForTrimmedEquality:value errorString:VstratorStrings.ErrorTitleBeginsOrEndsWithSpacesText outputString:outputString] && [self.class validateForLength:value minLength:1 maxLength:VstratorConstants.MaxTitleLength errorString:VstratorStrings.ErrorTitleHasInvalidLengthText outputString:outputString];
}

+ (BOOL)validateEmailAddress:(NSString *)value 
                outputString:(NSString **)outputString
{
    return [self.class validateForEmptyTrimmedValue:value errorString:VstratorStrings.ErrorEmailAddressIsEmptyText outputString:outputString] && [self.class validateForTrimmedEquality:value errorString:VstratorStrings.ErrorEmailAddressBeginsOrEndsWithSpacesText outputString:outputString] && [self.class validateForLength:value minLength:1 maxLength:VstratorConstants.MaxEmailLength errorString:VstratorStrings.ErrorEmailAddressHasInvalidLengthText outputString:outputString] && [self.class validateForEmailContent:value errorString:VstratorStrings.ErrorEmailAddressIsInvalidText outputString:outputString];
}

+ (BOOL)validatePassword:(NSString *)value 
            outputString:(NSString **)outputString
{
    return [self.class validateForEmptyTrimmedValue:value errorString:VstratorStrings.ErrorPasswordIsEmptyText outputString:outputString] && [self.class validateForLength:value minLength:6 maxLength:20 errorString:VstratorStrings.ErrorPasswordHasInvalidLengthText outputString:outputString];
}

+ (BOOL)validatePasswords:(NSString *)value 
              withConfirm:(NSString *)confirmValue 
             outputString:(NSString **)outputString
{
    if (![self.class validatePassword:value outputString:outputString])
        return NO;
    if ([value isEqualToString:confirmValue])
        return YES;
    [self.class addValidationError:VstratorStrings.ErrorPasswordsAreNotEqualText outputString:outputString];
    return NO;
}

+ (BOOL)validateSelectedSport:(NSString *)value 
                 outputString:(NSString **)outputString
{
    return ([self.class validateForEmptyTrimmedValue:value errorString:VstratorStrings.ErrorSelectedSportIsEmptyText outputString:outputString]);
}

+ (BOOL)validateSelectedAction:(NSString *)value 
                  outputString:(NSString **)outputString
{
    return ([self.class validateForEmptyTrimmedValue:value errorString:VstratorStrings.ErrorSelectedActionIsEmptyText outputString:outputString]);
}

+ (BOOL)validatePrimarySport:(NSString *)value 
                outputString:(NSString **)outputString
{
    return ([self.class validateForEmptyTrimmedValue:value errorString:VstratorStrings.ErrorPrimarySportIsEmptyText outputString:outputString]);
}

+ (BOOL)validateIssueDescription:(NSString *)value 
                    outputString:(NSString **)outputString
{
    return ([self.class validateForEmptyTrimmedValue:value errorString:VstratorStrings.ErrorIssueDescriptionIsEmptyText outputString:outputString]);
}

@end

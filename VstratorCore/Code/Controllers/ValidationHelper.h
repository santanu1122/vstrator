//
//  ValidationHelper.h
//  VstratorApp
//
//  Created by Mac on 14.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValidationHelper : NSObject

+ (BOOL)validateForEmptyValue:(NSString *)value 
                  errorString:(NSString *)errorString
                 outputString:(NSString **)outputString;
+ (BOOL)validateForTrimmedEquality:(NSString *)value 
                       errorString:(NSString *)errorString
                      outputString:(NSString **)outputString;
+ (BOOL)validateForLength:(NSString *)value
                minLength:(NSInteger)minLength
                maxLength:(NSInteger)maxLength
              errorString:(NSString *)errorString
             outputString:(NSString **)outputString;

+ (BOOL)validateFirstName:(NSString *)value 
             outputString:(NSString **)outputString;
+ (BOOL)validateSecondName:(NSString *)value 
              outputString:(NSString **)outputString;
+ (BOOL)validateTitle:(NSString *)value 
         outputString:(NSString **)outputString;

+ (BOOL)validateEmailAddress:(NSString *)value 
                outputString:(NSString **)outputString;

+ (BOOL)validatePassword:(NSString *)value 
            outputString:(NSString **)outputString;
+ (BOOL)validatePasswords:(NSString *)value 
              withConfirm:(NSString *)confirmValue 
             outputString:(NSString **)outputString;

+ (BOOL)validatePrimarySport:(NSString *)value 
                outputString:(NSString **)outputString;

+ (BOOL)validateSelectedSport:(NSString *)value 
                 outputString:(NSString **)outputString;
+ (BOOL)validateSelectedAction:(NSString *)value 
                  outputString:(NSString **)outputString;

+ (BOOL)validateIssueDescription:(NSString *)value 
                    outputString:(NSString **)outputString;

@end

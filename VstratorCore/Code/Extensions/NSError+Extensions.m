//
//  NSError+Extensions.m
//  VstratorApp
//
//  Created by Mac on 01.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "NSError+Extensions.h"
#import "VstratorConstants.h"

@implementation NSError (Extensions)

+ (NSError *)errorWithText:(NSString *)text
{
    // assert & log
    NSAssert(text != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    NSLog(@"Error with text: %@", text);
    // perform
    NSString *errorDescription = [NSString stringWithString:text];
    NSDictionary* errorDetails = @{NSLocalizedDescriptionKey: errorDescription};
    return [NSError errorWithDomain:@"vstratorApp" code:10000 userInfo:errorDetails];
}

+ (NSError *)errorWithError:(NSError *)error text:(NSString *)text;
{
    if (error == nil) {
        return [self errorWithText:text];
    } else {
        NSLog(@"Error: %@\nText: %@", error.localizedDescription, text);
        return [self errorWithText:text];
    }
}

- (BOOL)isURLTransferError
{
    return [self.domain isEqualToString:NSURLErrorDomain] && !(self.code == NSURLErrorUserCancelledAuthentication || self.code == NSURLErrorUserAuthenticationRequired);
}

@end

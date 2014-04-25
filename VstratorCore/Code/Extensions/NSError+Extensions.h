//
//  NSError+Extensions.h
//  VstratorApp
//
//  Created by Mac on 01.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Extensions)

+ (NSError *)errorWithText:(NSString *)text;
+ (NSError *)errorWithError:(NSError *)error text:(NSString *)text;

- (BOOL)isURLTransferError;

@end

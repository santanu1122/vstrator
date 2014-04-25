//
//  User+Extensions.h
//  VstratorApp
//
//  Created by user on 21.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "User.h"

typedef enum {
    UploadQualityHigh = 0,
    UploadQualityLow = 1,
} UploadQuality;

typedef enum {
    UploadOnlyOnWiFi, // Default
    UploadOnWWAN
} UploadOptions;

@class AccountInfo;


@interface User (Extensions)

+ (User *)createUserInContext:(NSManagedObjectContext*)context;
+ (User *)findUserWithIdentity:(NSString *)identity
                     inContext:(NSManagedObjectContext *)context
                         error:(NSError **)error;
+ (User *)findUserWithEmail:(NSString *)email
                  inContext:(NSManagedObjectContext *)context
                      error:(NSError **)error;
+ (User *)findUserWithFacebookIdentity:(NSString *)identity
                             inContext:(NSManagedObjectContext *)context
                                 error:(NSError **)error;
+ (User *)findUserWithPredicate:(NSPredicate *)predicate
                      inContext:(NSManagedObjectContext *)context
                          error:(NSError **)error;
+ (User *)findUserWithVstratorIdentity:(NSString *)vstratorIdentity
                             inContext:(NSManagedObjectContext *)context
                                 error:(NSError **)error;

@property (nonatomic, strong, readonly) UIImage *pictureImage;

- (BOOL)updateWithAccount:(AccountInfo *)accountInfo
                inContext:(NSManagedObjectContext *)context
                    error:(NSError **)error;

@end

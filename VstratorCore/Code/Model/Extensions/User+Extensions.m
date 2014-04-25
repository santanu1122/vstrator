//
//  User+Extensions.m
//  VstratorApp
//
//  Created by user on 21.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "User+Extensions.h"

#import "AccountInfo.h"
#import "Sport+Extensions.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@implementation User (Extensions)

+ (User *)createUserInContext:(NSManagedObjectContext *)context
{
    User *author = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    author.identity = [[NSProcessInfo processInfo] globallyUniqueString];
    return author;
}

+ (User *)findUserWithIdentity:(NSString *)identity
                     inContext:(NSManagedObjectContext *)context
                         error:(NSError **)error
{
    // checks
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // prepare
    //TODO: check if we need ==[c] instead of = here
    return [self.class findUserWithPredicate:[NSPredicate predicateWithFormat:@"identity ==[c] %@", identity]
                                   inContext:context
                                       error:error];
}

+ (User *)findUserWithVstratorIdentity:(NSString *)vstratorIdentity
                             inContext:(NSManagedObjectContext *)context
                                 error:(NSError **)error
{
    // checks
    NSParameterAssert(error);
    *error = nil;
    // prepare
    return [self.class findUserWithPredicate:[NSPredicate predicateWithFormat:@"vstratorIdentity ==[c] %@", vstratorIdentity]
                                   inContext:context
                                       error:error];
}

+ (User *)findUserWithEmail:(NSString *)email
                  inContext:(NSManagedObjectContext *)context
                      error:(NSError **)error
{
    // checks
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // prepare
    return [self.class findUserWithPredicate:[NSPredicate predicateWithFormat:@"email ==[cd] %@", email]
                                   inContext:context
                                       error:error];
}

+ (User *)findUserWithFacebookIdentity:(NSString *)identity
                             inContext:(NSManagedObjectContext *)context
                                 error:(NSError **)error
{
    // checks
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // prepare
    //TODO: check if we need ==[c] instead of = here
    return [self.class findUserWithPredicate:[NSPredicate predicateWithFormat:@"facebookIdentity ==[c] %@", identity]
                                   inContext:context
                                       error:error];
}

+ (User *)findUserWithPredicate:(NSPredicate *)predicate
                      inContext:(NSManagedObjectContext *)context
                          error:(NSError **)error
{
    // checks
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // prepare
	NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
	request.predicate = predicate;
    // query
	NSArray* matches = [context executeFetchRequest:request error:error];
    if (*error) {
        *error = [NSError errorWithError:*error text:VstratorStrings.ErrorDatabaseSelectText];
    }
	return (*error || matches == nil || matches.count <= 0) ? nil : matches.lastObject;
}

- (UIImage *)pictureImage
{
    return self.picture == nil ? nil : [[UIImage alloc] initWithData:self.picture];
}

- (BOOL)updateWithAccount:(AccountInfo *)accountInfo
                inContext:(NSManagedObjectContext *)context
                    error:(NSError **)error
{
    // checks
    NSParameterAssert(error);
    *error = nil;
    // prepare
    self.email = accountInfo.email;
    self.facebookAccessToken = accountInfo.facebookAccessToken;
    self.facebookExpirationDate = accountInfo.facebookExpirationDate;
    self.facebookIdentity = accountInfo.facebookIdentity;
    self.firstName = accountInfo.firstName;
    if ([NSString isNilOrEmpty:self.identity])
        self.identity = accountInfo.identity;
    self.lastName = accountInfo.lastName;
    self.password = accountInfo.password;
    self.picture = accountInfo.picture;
    self.pictureUrl = accountInfo.pictureUrl;
    self.primarySport = accountInfo.primarySportName == nil ? nil : [Sport sportWithName:accountInfo.primarySportName inContext:context error:error];
    self.tipCamera = accountInfo.tipCamera;
    self.tipSession = accountInfo.tipSession;
    self.tipWelcome = accountInfo.tipWelcome;
    self.twitterIdentity = accountInfo.twitterIdentity;
    self.uploadQuality = @(accountInfo.uploadQuality);
    self.uploadOptions = @(accountInfo.uploadOptions);
    self.vstratorIdentity = accountInfo.vstratorIdentity;
    self.vstratorUserName = accountInfo.vstratorUserName;
    return !*error;
}

@end

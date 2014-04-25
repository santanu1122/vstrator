//
//  ServiceFactory.m
//  VstratorApp
//
//  Created by Mac on 03.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <NSData+Base64.h>
#import "AccountController2.h"
#import "DescriptorBuilder.h"
#import "RKSerializationStub.h"
#import "RestDownloadService.h"
#import "RestNotificationService.h"
#import "RestUploadService.h"
#import "RestUsersService.h"
#import "ServiceFactory.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

static ServiceFactory* SharedInstance;

@implementation ServiceFactory

@synthesize baseURL = _baseURL;
@synthesize objectManager = _objectManager;

//#ifdef DEBUG_RESTKIT
// TODO: add AppSettings.json
+(void)initialize
{
//    NSDictionary* restkitSettings = self.settings[@"restkit"];
//    if ([restkitSettings[@"debug_network"] boolValue]) {
//        RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
//    }
//    if ([restkitSettings[@"debug_mapping"] boolValue]) {
//        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//    }
    [RKMIMETypeSerialization registerClass:[RKSerializationStub class] forMIMEType:@"text/html"];
    [RKMIMETypeSerialization registerClass:[RKSerializationStub class] forMIMEType:@"text/plain"];
}
//#endif

+(ServiceFactory *)sharedInstance
{
    return SharedInstance ? SharedInstance : (SharedInstance = [ServiceFactory new]);
}

#pragma mark - RemoteServiceDelegate

-(RKObjectManager *)objectManager
{
    if (_objectManager) return _objectManager;
    
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:[self createClient]];
    _objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    DescriptorBuilder* builder = [DescriptorBuilder new];
    [builder parseDescriptorsSettings:[self.class descriptorsSettings]];
    [_objectManager addResponseDescriptorsFromArray:builder.responseDescriptors];
    [_objectManager addRequestDescriptorsFromArray:builder.requestDescriptors];
    
    // Add the error mapping
    RKObjectMapping* errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"message" toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    [_objectManager addResponseDescriptor:errorDescriptor];
    
    return _objectManager;
}

-(NSDictionary *)parameters
{
    return nil;
}

-(BOOL)userIsLoggedIn
{
    return [AccountController2 sharedInstance].userLoggedIn;
}

#pragma mark -

-(NSURL *)baseURL
{
    return _baseURL ? _baseURL : (_baseURL = [NSURL URLWithString:[VstratorConstants VstratorApiUrl]]);
}

-(void) setBaseURL:(NSURL *)baseURL
{
    NSAssert(baseURL, VstratorStrings.ErrorBaseUrlIsNilOrInvalidText);
    if (![_baseURL isEqual:baseURL]) {
        _baseURL = baseURL;
        _objectManager = nil;
    }
}

-(void) setVstratorAuthWithEmail:(NSString*)email password:(NSString*)password
{
    NSAssert(![NSString isNilOrEmpty:email] && ![NSString isNilOrEmpty:password], VstratorStrings.ErrorCredentialsAreNilOrInvalidText);
    [self clearAuth];
    NSString* userName = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
    [self.objectManager.HTTPClient setAuthorizationHeaderWithUsername:userName password:password];
}

-(void) setFacebookAuthWithIdentity:(NSString*)identity accessToken:(NSString*)accessToken
{
    NSAssert(![NSString isNilOrEmpty:identity] && ![NSString isNilOrEmpty:accessToken], VstratorStrings.ErrorCredentialsAreNilOrInvalidText);
    [self clearAuth];
    NSData *authData = [[NSString stringWithFormat:@"%@:%@", identity, accessToken] dataUsingEncoding:NSUTF8StringEncoding];
	NSString *authString = [[authData.base64EncodedString componentsSeparatedByString:@"\r\n"] componentsJoinedByString:@""];
	NSString *authHttpHeader = [NSString stringWithFormat:@"Facebook %@", authString];
    [self.objectManager.HTTPClient.defaultHeaders setValue:authHttpHeader forKey:@"Authorization"];
}

-(void) clearAuth
{
    [self.objectManager.HTTPClient clearAuthorizationHeader];
}

-(id)createService:(Class)class
{
    id service = [[class alloc] init];
    [service setDelegate:self];
    return service;
}

-(id<UsersService>)createUsersService
{
    return [self createService:RestUsersService.class];
}

-(id<DownloadService>)createDownloadService
{
    return [self createService:RestDownloadService.class];
}

-(id<UploadService>)createUploadService
{
    return [self createService:RestUploadService.class];
}

-(id<NotificationService>)createNotificationService
{
    return [self createService:RestNotificationService.class];
}

#pragma mark - Utils

-(AFHTTPClient*)createClient
{
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:self.baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [client setDefaultHeader:@"X-Vstrator-App-Id" value:[VstratorConstants ApplicationId]];
    return client;
}

+(NSDictionary*)settings
{
    static NSDictionary* s;
    return s ? s : (s = [self JSONSettingsFromFile:@"AppSettings"]);
}

+(NSDictionary*)descriptorsSettings
{
    static NSDictionary* s;
    return s ? s : (s = [self JSONSettingsFromFile:@"Descriptors"]);
}

+(NSDictionary*)JSONSettingsFromFile:(NSString*)fileName
{
    NSError* error = nil;
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"VstratorModels" ofType:@"bundle"];
    NSURL *url = [[NSBundle bundleWithPath:bundlePath] URLForResource:fileName withExtension:@"json"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSDictionary* settings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSAssert2(!error && settings, @"Cannot load settings from file '%@.json'. Error: %@", fileName, error);
    return settings;
}

@end

//
//  DescriptorBuilder.m
//  VstratorCore
//
//  Created by akupr on 05.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "DescriptorBuilder.h"
#import "Mappable.h"

@interface DescriptorBuilder() {
    NSMutableArray* _responseDescriptors;
    NSMutableArray* _requestDescriptors;
}

@end

@implementation DescriptorBuilder

@synthesize responseDescriptors = _responseDescriptors;
@synthesize requestDescriptors = _requestDescriptors;

-(id)init
{
    self = [super init];
    if (self) {
        _responseDescriptors = [NSMutableArray array];
        _requestDescriptors = [NSMutableArray array];
    }
    return self;
}

-(RKResponseDescriptor*)addResponseDescriptorFromObject:(NSDictionary *)object
{
    Class objectClass = NSClassFromString(object[@"class"]);
    NSParameterAssert(objectClass);
    SEL selector = object[@"mapping"] ? NSSelectorFromString(object[@"mapping"]) : @selector(mapping);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    RKObjectMapping* mapping = selector && [objectClass respondsToSelector:selector]? [objectClass performSelector:selector] : nil;
#pragma clang diagnostic pop
    NSAssert1(mapping.objectClass == objectClass, @"Incorrect mapping for class '%@'", object[@"class"]);
    int statusCodes = [object[@"status_codes"] intValue];
    RKRequestMethod method = object[@"method"] ? RKRequestMethodFromString(object[@"method"]) : RKRequestMethodAny;
    RKResponseDescriptor* d = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                           method:method
                                                                      pathPattern:object[@"path"]
                                                                          keyPath:object[@"root"]
                                                                      statusCodes:RKStatusCodeIndexSetForClass(statusCodes ? statusCodes : RKStatusCodeClassSuccessful)];
    [_responseDescriptors addObject:d];
    return d;
}

-(RKRequestDescriptor *)addRequestDescriptorFromObject:(NSDictionary *)object
{
    Class objectClass = NSClassFromString(object[@"class"]);
    NSParameterAssert(objectClass);
    SEL selector = object[@"mapping"] ? NSSelectorFromString(object[@"mapping"]) : @selector(serialization);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    RKObjectMapping* mapping = selector && [objectClass respondsToSelector:selector]? [objectClass performSelector:selector] : nil;
#pragma clang diagnostic pop
    NSAssert1(mapping.objectClass == [NSMutableDictionary class], @"Incorrect request mapping for class '%@'", object[@"class"]);
    RKRequestMethod method = object[@"method"] ? RKRequestMethodFromString(object[@"method"]) : RKRequestMethodAny;
    RKRequestDescriptor* d = [RKRequestDescriptor requestDescriptorWithMapping:mapping
                                                                   objectClass:objectClass
                                                                   rootKeyPath:object[@"root"]
                                                                        method:method];
    [_requestDescriptors addObject:d];
    return d;
}

-(void)parseDescriptorsSettings:(NSDictionary *)settings
{
    for (NSDictionary* d in settings[@"requests"]) {
        [self addRequestDescriptorFromObject:d];
    }
    for (NSDictionary* d in settings[@"responses"]) {
        [self addResponseDescriptorFromObject:d];
    }
}

@end

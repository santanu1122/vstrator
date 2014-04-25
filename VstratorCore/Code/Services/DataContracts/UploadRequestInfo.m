//
//  UploadRequestInfo.m
//  VstratorApp
//
//  Created by user on 17.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "UploadRequestInfo.h"

@interface UploadRequestInfo() {
    NSMutableArray* _data;
}

@end

@implementation UploadRequestInfo

@synthesize data = _data;

-(id)init
{
    self = [super init];
    if (self) {
        _data = [NSMutableArray array];
    }
    return self;
}

-(void)addUploadData:(UploadData *)data
{
    [_data addObject:data];
}

+(RKObjectMapping *)mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[UploadRequestInfo class]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"uploadUrl": @"uploadURL",
     @"recordingKey": @"recordingKey"}];
	return mapping;
}

@end

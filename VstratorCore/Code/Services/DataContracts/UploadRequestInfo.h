//
//  UploadRequestInfo.h
//  VstratorApp
//
//  Created by user on 17.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mappable.h"

@class UploadData;

@interface UploadRequestInfo : NSObject<Mappable>

@property (nonatomic, copy) NSString* identity;
@property (nonatomic) BOOL isVstration;
@property (nonatomic, strong) NSArray* data;

-(void)addUploadData:(UploadData*)data;

@property (nonatomic, copy) NSURL* uploadURL;
@property (nonatomic, copy) NSString* recordingKey;

@end

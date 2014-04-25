//
//  UploadData.h
//  VstratorApp
//
//  Created by user on 16.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadFile+Extensions.h"

@interface UploadData : NSObject

@property (nonatomic, copy) NSString* identity;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* mimeType;
@property (nonatomic, strong) NSURL* url;
@property (nonatomic, strong) NSData* content;
@property (nonatomic) UploadFileType type;

-(BOOL)prepareWithRecordingKey:(NSString*)recordingKey error:(NSError**)error;

@end


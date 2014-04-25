//
//  DownloadService.h
//  VstratorApp
//
//  Created by akupr on 31.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeInfo.h"

@protocol DownloadService <NSObject>

-(void)getAvailableMediaTypesWithCallback:(void (^)(NSArray *types, NSError *error))callback;
-(void)getMediaListForType:(DownloadMediaType)type callback:(void(^)(NSArray* mediaList, NSError* error))callback;
-(void)downloadDataByURL:(NSURL*)url callback:(void(^)(NSData *data, NSError *error))callback;
-(void)getContentSets:(void(^)(NSArray* array, NSError* error))callback;
-(void)validateReceipt:(NSData*)receipt forContentSetIdentity:(NSString*)identity callback:(void(^)(NSDictionary* object, NSError* error))callback;
-(void)getContentSetWithIdentity:(NSString*)identity callback:(void(^)(NSDictionary* set, NSError* error))callback;

@end

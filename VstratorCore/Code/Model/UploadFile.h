//
//  UploadFile.h
//  VstratorCore
//
//  Created by akupr on 08.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UploadRequest;

@interface UploadFile : NSManagedObject

@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * uploadDate;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) UploadRequest *request;

@end

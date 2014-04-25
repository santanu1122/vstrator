//
//  MarkupDataCollection.h
//  VstratorApp
//
//  Created by akupr on 20.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MarkupData, Session;

@interface MarkupDataCollection : NSObject

@property (nonatomic, strong) NSArray* markup;
@property (nonatomic, readonly) NSString* asJSONString;

-(id)initWithSession:(Session*)session error:(NSError**)error;

-(void)add:(MarkupData*)data;
-(NSArray*)serialize:(NSError**)error;
-(NSString *)asJSONString:(NSError**)error;

@end

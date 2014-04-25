//
//  ExerciseInfo.h
//  VstratorApp
//
//  Created by Lion User on 30/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Exercise, Media;

@interface ExerciseInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString * equipment;
@property (nonatomic, strong) NSNumber *sortOrder;
@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) NSArray *params;
@property (nonatomic, strong) Exercise *exercise;

@end

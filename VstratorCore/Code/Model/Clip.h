//
//  Clip.h
//  VstratorCore
//
//  Created by Admin1 on 09.10.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Media.h"

@class Session;

@interface Clip : Media

@property (nonatomic, retain) NSNumber * fakeAttribute;
@property (nonatomic, retain) NSNumber * frameRate;
@property (nonatomic, retain) NSSet *session;
@property (nonatomic, retain) NSSet *sideBySide;
@end

@interface Clip (CoreDataGeneratedAccessors)

- (void)addSessionObject:(Session *)value;
- (void)removeSessionObject:(Session *)value;
- (void)addSession:(NSSet *)values;
- (void)removeSession:(NSSet *)values;

- (void)addSideBySideObject:(Session *)value;
- (void)removeSideBySideObject:(Session *)value;
- (void)addSideBySide:(NSSet *)values;
- (void)removeSideBySide:(NSSet *)values;

@end

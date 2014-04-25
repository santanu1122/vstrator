//
//  Session+Extensions.h
//  VstratorApp
//
//  Created by user on 17.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Session.h"
#import "Media.h"

@interface Session (Extensions)

+(Session *) createSessionWithClip:(Clip *)clip author:(User *)author inContext:(NSManagedObjectContext *)context;
+(Session *) createSideBySideWithClip:(Clip *)clip clip2:(Clip *)clip2 author:(User *)author inContext:(NSManagedObjectContext *)context;

@property (nonatomic, readonly) BOOL isSideBySide;
@property (nonatomic, readonly) NSURL *audioFileURL;

@end

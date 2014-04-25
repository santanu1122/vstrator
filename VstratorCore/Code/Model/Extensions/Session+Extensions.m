//
//  Session+Extensions.m
//  VstratorApp
//
//  Created by user on 17.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Session+Extensions.h"
#import "Clip.h"
#import "NSString+Extensions.h"

@implementation Session (Extensions)

#pragma mark Helpers

+(Session *) createSessionWithClip:(Clip *)clip author:(User *)author inContext:(NSManagedObjectContext *)context
{
	Session *session = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:context];
	session.action = clip.action;
	session.audioFileName = [[NSProcessInfo processInfo] globallyUniqueString];
	session.author = author == nil ? clip.author : author;
	session.date = [NSDate date];
	session.duration = clip.duration;
	session.identity = [[NSProcessInfo processInfo] globallyUniqueString];
	session.originalClip = clip;
	session.thumbnail = clip.thumbnail;
    session.title = clip.title;
	session.url = [[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:
                                           [NSString stringWithFormat:@"Documents/%@.mp4", session.identity]]] absoluteString];
    session.width = clip.width;
    session.height = clip.height;
	return session;
}

+(Session *) createSideBySideWithClip:(Clip *)clip clip2:(Clip *)clip2 author:(User *)author inContext:(NSManagedObjectContext *)context
{
    Session *session = [self createSessionWithClip:clip author:author inContext:context];
    if (clip2 != nil) {
        session.originalClip2 = clip2;
        session.url2 = clip2.url;
    }
    return session;
}

#pragma mark Properties

-(BOOL) isSideBySide
{
    return (self.url2 != nil);
}

-(NSURL *) audioFileURL
{
    //NOTE: the same code exists and MUST exist in VstrationSessionModel.m
	if ([NSString isNilOrWhitespace:self.audioFileName])
        return nil;
	NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return [NSURL fileURLWithPath:[path stringByAppendingPathComponent:self.audioFileName]];
}

#pragma mark Lifecycle

-(void) didSave
{
    if (self.isDeleted) {
        if (self.audioFileURL) {
            if ([NSFileManager.defaultManager fileExistsAtPath:self.audioFileURL.path])
                [NSFileManager.defaultManager removeItemAtPath:self.audioFileURL.path error:nil];
        }
    }
    [super didSave];
}

@end

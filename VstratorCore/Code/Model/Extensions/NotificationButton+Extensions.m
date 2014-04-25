//
//  NotificationButton+Extensions.m
//  VstratorCore
//
//  Created by akupr on 24.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "NotificationButton+Extensions.h"
#import "NotificationButtonInfo.h"

@implementation NotificationButton (Extensions)

+(NotificationButton *)buttonFromButtonInfo:(NotificationButtonInfo *)info inContext:(NSManagedObjectContext *)context
{
    NotificationButton* button = [NSEntityDescription insertNewObjectForEntityForName:@"NotificationButton" inManagedObjectContext:context];
    button.identity = info.identity;
    button.text = info.text;
    button.type = [NSNumber numberWithInt:info.type];
    button.mediaType = [NSNumber numberWithInt:info.mediaType];
    button.mediaIdentity = info.mediaIdentity;
    button.clickURL = info.clickURL.absoluteString;
    return button;
}

@end

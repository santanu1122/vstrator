//
//  NotificationButtonInfo.h
//  VstratorCore
//
//  Created by akupr on 22.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mappable.h"
#import "MediaTypeInfo.h"
#import "NotificationTypes.h"

@interface NotificationButtonInfo : NSObject<Mappable>

@property (nonatomic, copy) NSString* identity; // GUID
@property (nonatomic, copy) NSString* text;
@property (nonatomic) NotificationButtonType type;
@property (nonatomic) DownloadMediaType mediaType; // Used only if button type is Media download
@property (nonatomic, copy) NSString* mediaIdentity; // Used only if button type is Media download
@property (nonatomic, strong) NSURL* clickURL;

@end

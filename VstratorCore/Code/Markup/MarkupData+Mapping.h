//
//  MarkupData+Mapping.h
//  VstratorApp
//
//  Created by akupr on 22.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MarkupData.h"
#import "LayoutInfo.h"
#import "StrokeInfo.h"
#import "TransformInfo.h"
#import "MarkupDataCollection.h"

@class RKObjectMapping;

@interface LayoutInfo (Mapping)

+(RKObjectMapping*)mapping;

@end

@interface StrokeInfo (Mapping)

+(RKObjectMapping*)mapping;

@end

@interface TransformInfo (Mappint)

+(RKObjectMapping*)mapping;

@end

@interface MarkupData (Mapping)

+(RKObjectMapping*)mapping;

@end

@interface MarkupDataCollection (Mapping)

+(RKObjectMapping*)mapping;

@end

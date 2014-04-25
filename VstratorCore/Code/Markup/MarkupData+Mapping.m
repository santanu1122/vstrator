//
//  MarkupData+Mapping.m
//  VstratorApp
//
//  Created by akupr on 22.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "MarkupData+Mapping.h"

@implementation MarkupDataCollection (Mapping)

+(RKObjectMapping *)mapping
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"markup" mapping:[MarkupData mapping]];
    return mapping;
}

@end

@implementation MarkupData (Mapping)

+(RKObjectMapping *)mapping
{
	RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{
     @"actionTimeSpan": @"ActionTime",
     @"markupTimeSpan": @"MarkupTime",
     @"appScreenMode": @"AppScreenMode",
     @"drawingToolMode": @"DrawingToolMode",
     @"dataFormat": @"DataFormat",
     @"showFrame": @"ShowFrame",
     @"inFrame": @"InFrame",
     @"outFrame": @"OutFrame"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"primaryLayout" toKeyPath:@"PrimaryLayout" withMapping:[LayoutInfo mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"secondaryLayout" toKeyPath:@"SecondaryLayout" withMapping:[LayoutInfo mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"strokeObject" toKeyPath:@"StrokeObject" withMapping:[StrokeInfo mapping]]];
	return mapping;
}

@end

@implementation LayoutInfo (Mapping)

+(RKObjectMapping *)mapping
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{
     @"imageIndex": @"ImageIndex",
     @"left": @"Left",
     @"top": @"Top",
     @"width": @"Width",
     @"height": @"Height",
     @"rotation": @"Rotation",
     @"clipKey": @"ClipKey",
      @"opacity": @"Opacity"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"transform" toKeyPath:@"Transform" withMapping:[TransformInfo mapping]]];
    return mapping;
}

@end

@implementation StrokeInfo (Mapping)

+(RKObjectMapping *)mapping
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{
     @"width": @"Width",
     @"height": @"Height",
     @"colorComponents32ForColor": @"Color",
     @"colorComponents32ForOutlineColor": @"OutlineColor",
      @"points": @"Points"}];
    return mapping;
}

@end

@implementation TransformInfo (Mapping)

+ (RKObjectMapping *)mapping
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{
     @"m11": @"m11",
     @"m12": @"m12",
     @"m21": @"m21",
      @"m22": @"m22"}];
    return mapping;
}

@end
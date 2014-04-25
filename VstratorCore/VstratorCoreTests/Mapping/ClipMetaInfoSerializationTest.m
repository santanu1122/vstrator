//
//  ClipMetaInfoSerializationTest.m
//  VstratorCore
//
//  Created by akupr on 12.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ClipMetaInfoSerializationTest.h"
#import "ClipMetaInfo.h"

@interface ClipMetaInfoSerializationTest() {
    RKMappingTest* mappingTest;
    ClipMetaInfo* source;
    NSMutableDictionary* result;
}

@end

@implementation ClipMetaInfoSerializationTest

- (void)setUp
{
    [super setUp];
    source = [ClipMetaInfo new];
    result = [NSMutableDictionary new];
    mappingTest = [RKMappingTest testForMapping:[ClipMetaInfo serialization] sourceObject:source destinationObject:result];
}

-(void)testThatTitleIsMapped
{
    source.title = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"title"]).to.equal(@"Foo");
}

-(void)testThatRecordingKeyIsMapped
{
    source.recordingKey = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"recordingKey" destinationKeyPath:@"recordingKey"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"recordingKey"]).to.equal(@"Foo");
}

-(void)testThatUserKeyIsMapped
{
    source.userKey = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"userKey" destinationKeyPath:@"userKey"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"userKey"]).to.equal(@"Foo");
}

-(void)testThatSportIsMapped
{
    source.sport = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"sport" destinationKeyPath:@"sport"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"sport"]).to.equal(@"Foo");
}

-(void)testThatActionIsMapped
{
    source.action = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"action" destinationKeyPath:@"action"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"action"]).to.equal(@"Foo");
}

-(void)testThatOriginalFileNameIsMapped
{
    source.originalFileName = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"originalFileName" destinationKeyPath:@"originalFileName"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"originalFileName"]).to.equal(@"Foo");
}

-(void)testThatActivityDateIsMapped
{
    NSString* dateString = @"9/25/13, 2:36 PM";
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    source.activityDate = [formatter dateFromString:@"9/25/13, 2:36 PM"];
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"activityDateFormatted" destinationKeyPath:@"activityDate"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"activityDate"]).to.equal(dateString);
}

-(void)testThatFramesKeyIsMapped
{
    source.framesKey = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"framesKey" destinationKeyPath:@"framesKey"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"framesKey"]).to.equal(@"Foo");
}

@end

//
//  MediaSerializationTest.m
//  VstratorCore
//
//  Created by akupr on 13.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "SenTestCase+CoreData.h"
#import "Action+Extensions.h"
#import "MediaSerializationTest.h"
#import "Media+Mappable.h"

@interface MediaSerializationTest() {
    RKMappingTest* mappingTest;
    Media* source;
    NSMutableDictionary* result;
}

@end

@implementation MediaSerializationTest

- (void)setUp
{
    [super setUp];
    [self setupCoreDataStack];
    source = [Media createEntity];
    result = [NSMutableDictionary new];
    mappingTest = [RKMappingTest testForMapping:[Media serialization] sourceObject:source destinationObject:result];
}

-(void)tearDown
{
    [self cleanupCoreDataStack];
}

-(void)testThatTitleIsMapped
{
    source.title = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"title"]).to.equal(@"Foo");
}

-(void)testThatVideoKeyIsMapped
{
    source.videoKey = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"videoKey" destinationKeyPath:@"videoKey"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"videoKey"]).to.equal(@"Foo");
}

-(void)testThatActionAndSportAreMapped
{
    NSError* error = nil;
    source.action = [Action actionWithName:@"Serve" sportName:@"Tennis" inContext:source.managedObjectContext error:&error];
    expect(error).to.beNil();
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"action.name" destinationKeyPath:@"action"]];
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"action.sport.name" destinationKeyPath:@"sport"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"action"]).to.equal(@"Serve");
    expect(result[@"sport"]).to.equal(@"Tennis");
}

-(void)testThatNotesIsMapped
{
    source.note = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"note" destinationKeyPath:@"notes"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"notes"]).to.equal(@"Foo");
}

-(void)testThatIsPrivateIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"isPrivate" destinationKeyPath:@"isPrivate"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"isPrivate"]).to.equal(@NO);
}

-(void)testThatIsPublicIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"isPublic" destinationKeyPath:@"isPublic"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"isPublic"]).to.equal(@YES);
}


@end

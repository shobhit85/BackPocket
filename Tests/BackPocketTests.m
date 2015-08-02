//
//  BackPocketTests.m
//  BackPocket
//
//  Created by Shobhit Agarwal on 8/1/15.
//  Copyright (c) 2015 Shobhit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BackPocket.h"

@interface BackPocketTests : XCTestCase
{
    NSDictionary *props;
    PocketFactory *pocketFactory;
}

@end

@implementation BackPocketTests

- (void)setUp {
    [super setUp];
    props = [[NSMutableDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"localhost", @"8080", nil] forKeys:[[NSArray alloc] initWithObjects:@"server-address", @"server-port", nil]];
    pocketFactory = [BackPocket getPocketFactory:props];
}

- (void)tearDown {
    [super tearDown];
    pocketFactory = nil;
    props = nil;
}

- (void)testNotNilPocket {
    Pocket *cache = [pocketFactory create];
    XCTAssertNotNil(cache, @"Cache must not be nil!");
}

- (void)testCraeteAndGetDataStore {
    Pocket *cache = [pocketFactory create];
    DataStore *store = [cache createDatastore:@"teststore"];
    XCTAssertNotNil(store, @"Store created from cache must not be nil!");
    DataStore *retrievedStore = [cache getDatastore:@"teststore"];
    XCTAssertNotNil(retrievedStore, @"Store retrieved from cache must not be nil!");
    XCTAssertEqual(store, retrievedStore, @"Created and retrieved stores must be same!");
}

@end

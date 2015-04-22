//
//  PocketFactory.m
//
//  Created by Shobhit Agarwal on 1/3/13.
//
#import "PocketFactory.h"

@implementation PocketFactory

@synthesize properties;

- (id) initWithProps:(NSDictionary *)props
{
    if ((self = [super init])) {
        self.properties = [props copy];
    }
    return self;
}

- (Pocket *)create
{
    Pocket *cache = [[Pocket alloc] init];

    [cache initializeWithProps:(self.properties)];
    
    return cache;
}

@end

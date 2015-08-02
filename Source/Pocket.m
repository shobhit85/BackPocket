//
//  ClientCache.m
//
//  Created by Shobhit Agarwal on 1/3/13.
//

#import "Pocket.h"

@interface Pocket (privatemethods)

@property (atomic, retain) NSDictionary *regions;

@end

@implementation Pocket
{
    CFMutableDictionaryRef stores;
}

@synthesize server;
@synthesize port;

- (void)initializeWithProps:(NSDictionary *)ps
{
    // Initialize the cache
    server = [(NSString *)[ps valueForKey:@"server-address"] copy];
    port = [[ps valueForKey:@"server-port"] integerValue];
    stores = CFDictionaryCreateMutable(NULL, 5, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

- (DataStore *) createDatastore:(NSString *)storeName
{
    DataStore * store = nil;
    
    if (storeName != nil) {
        // Create pool using properties
        Pool *pool = [PoolManager createPoolWithAddress:(server) port:&(port)];
        store = [[DataStore alloc] initWithPool:pool name:storeName];
        CFDictionaryAddValue(stores, (__bridge const void *)(storeName), (__bridge const void *)(store));
    } else {
        NSException* storeNameException = [NSException
                                    exceptionWithName:@"StoreNameMissingException"
                                    reason:@"Please provide a name for the store"
                                    userInfo:nil];
        @throw storeNameException;
    }
    
    return store;
}

- (DataStore *) getDatastore:(NSString *)storeName
{
    return CFDictionaryGetValue(stores, (__bridge const void *)(storeName));
}


- (void) destroyDataStore:(NSString *)storeName
{
    CFDictionaryRemoveValue(stores, (__bridge const void *)(storeName));
}

- (void) close
{
    // TODO: Close all stores with shutdown of their connection pool.
}

@end

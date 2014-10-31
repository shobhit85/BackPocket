//
//  SampleObjectCacheAppDelegate.m
//  SampleObjectCache
//
//  Created by Shobhit Agarwal on 3/24/13.
//  Copyright (c) 2013 shobhita. All rights reserved.
//

#import "SampleObjectCacheAppDelegate.h"

NSString *CacheServerAddress = @"localhost";
NSString *CacheServerPort = @"8889";
NSString *SampleDataStoreName = @"demounit";

@implementation SampleObjectCacheAppDelegate

@synthesize window;

- (Pocket *)loadCache
{
    if (!cache) {
        NSDictionary *props = [NSDictionary dictionaryWithObjects:
                     [NSArray arrayWithObjects: CacheServerAddress, CacheServerPort, nil]
                    forKeys:[NSArray arrayWithObjects:@"server-address", @"server-port", nil]];
        cache = [[BackPocket getPocketFactory:props] create];
    }
    
    return cache;
}

- (NSObject *) objectInListAtIndex:(NSInteger)key
{
    if (cache) {
        store = [cache getDatastore:SampleDataStoreName];
        if (!store) {
            store = [cache createDatastore:SampleDataStoreName];
        }
    }
    
    NSObject *value = [store get:[NSNumber numberWithInteger:key]];
    
    return value;
}

- (NSInteger) cacheSize
{
    if (cache) {
        store = [cache getDatastore:SampleDataStoreName];
        if (!store) {
            store = [cache getDatastore:SampleDataStoreName];
        }
    }
    
    return [store getSize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadCache];
    
    // Insert sample data in cache
    if (cache) {
        
        store = [cache getDatastore:SampleDataStoreName];
        if (!store) {
            store = [cache getDatastore:SampleDataStoreName];
        }
        
        // Adding valuei for i
        for (int i=1; i<= 10; i++) {
            [store put:[NSString stringWithFormat:@"%@%d", @"value", i] forKey:[NSNumber numberWithInt:i]];
        }
    }
    
    return YES;
}


+ (SampleObjectCacheAppDelegate *)sharedDelegate {
    
    return (SampleObjectCacheAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
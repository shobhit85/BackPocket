//
//  SampleObjectCacheAppDelegate.h
//  SampleObjectCache
//
//  Created by Shobhit Agarwal on 3/24/13.
//  Copyright (c) 2013 shobhita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BackPocket.h>

@class SampleObjectCacheMasterViewController;

@interface SampleObjectCacheAppDelegate : UIResponder <UIApplicationDelegate>
{
    Pocket *cache;
    DataStore *store;

}

- (NSInteger) cacheSize;

- (NSObject *) objectInListAtIndex:(NSInteger)key;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SampleObjectCacheMasterViewController *viewController;

@property (nonatomic, readonly) Pocket *loadCache;

+ (SampleObjectCacheAppDelegate *)sharedDelegate;

@end

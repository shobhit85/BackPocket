//
//  ClientCache.h
//
//  Created by Shobhit Agarwal on 1/3/13.
//

#import <Foundation/Foundation.h>
#import "DataStore.h"
#import "PoolManager.h"

@interface Pocket : NSObject
{
    NSString *server;
    NSInteger port;
}

@property (copy, nonatomic) NSString *server;
@property (readonly, nonatomic) NSInteger port;

- (void) initializeWithProps:(NSDictionary *) props;

- (DataStore *)createDatastore: (NSString *)storeName;

- (DataStore *)getDatastore: (NSString *)storeName;

- (void)destroyDataStore: (NSString *)storeName;

- (void)close;

@end

//
//  PoolManager.h
//
//  Created by Shobhit Agarwal on 1/6/13.
//

#import <Foundation/Foundation.h>
#import "Pool.h"

#define INIT_NUM_CONN 5

@interface PoolManager : NSObject

+ (Pool *)createPoolWithAddress:(NSString *)server port:(NSInteger *)port;

@end
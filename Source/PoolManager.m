//
//  PoolManager.m
//
//  Created by Shobhit Agarwal on 1/6/13.
//

#import "PoolManager.h"

@implementation PoolManager

+ (Pool *)createPoolWithAddress:(NSString *)server port:(NSInteger *)port
{
    Pool *pool = [[Pool alloc] initialize:(server) port:*((port)) numConn:((int)INIT_NUM_CONN)];
    return pool;
}


@end

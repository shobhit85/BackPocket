//
//  Created by Shobhit Agarwal on 1/3/13.
//
#import "BackPocket.h"

@implementation BackPocket

+ (PocketFactory *) getPocketFactory: (NSDictionary *)props
{
    return [[PocketFactory alloc] initWithProps:props];
}


@end
//
//  Created by Shobhit Agarwal on 1/3/13.
//

#import <Foundation/Foundation.h>
#import "PocketFactory.h"

@interface BackPocket : NSObject

+ (PocketFactory *) getPocketFactory:(NSDictionary *) props;

@end
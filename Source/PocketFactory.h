//
//  PocketFactory.h
//
//  Created by Shobhit Agarwal on 1/3/13.
//

#import <Foundation/Foundation.h>
#import "Pocket.h"

@interface PocketFactory : NSObject
{
    NSDictionary *properties;
}

@property (copy, getter = getProps) NSDictionary *properties;

- (id) initWithProps:(NSDictionary *)props;

- (Pocket *)create;

@end

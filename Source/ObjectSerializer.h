//
//  ObjectSerializer.h
//
//  Created by Shobhit Agarwal on 10/12/13.
//

#import <Foundation/Foundation.h>

@protocol ObjectSerializer <NSObject>

@required

- (NSData *) serialize:(NSObject *)object;

- (NSObject *) deserialize: (NSData *)bytes;

@end

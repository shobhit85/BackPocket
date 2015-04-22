//
//  Pool.h
//
//  Created by Shobhit Agarwal on 1/6/13.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@interface Pool : NSObject
{
    NSString *server;
    NSInteger port;
}

@property (retain, nonatomic) NSString *server;
@property (assign, readwrite) NSInteger port;

- (id)initialize:(NSString *)serverAddress port:(NSInteger )port numConn:(int)conns;

- (Connection *) getConnection;

@end

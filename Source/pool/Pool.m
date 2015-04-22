//
//  Pool.m
//
//  Created by Shobhit Agarwal on 1/6/13.
//

#import "Pool.h"

@interface Pool (privatemethods)

- (Connection *) getFreeConnection;

@end

@implementation Pool {

    CFMutableSetRef connections;
    CFMutableArrayRef freeConnections;
    int16_t numOfConn;

}

@synthesize port;
@synthesize server;

- (id)initialize:(NSString *)serverAddress port:(NSInteger )p numConn:(int)conns
{
    self.server = serverAddress;
    self.port = p;
    numOfConn = conns;
    connections = CFSetCreateMutable(kCFAllocatorDefault, conns, NULL);
    freeConnections = CFArrayCreateMutable(kCFAllocatorDefault, conns, NULL);
    return self;
}

- (Connection *) getConnection {
    
    Connection * conn = NULL;

    if ((int16_t)CFSetGetCount(connections) < numOfConn) {
        conn = [[Connection alloc] initWithIp:[server UTF8String] andPort:(int)port];
    } else {
        // Get a free connection;
        // This call will hang until a connection becomes available.
        conn = [self getFreeConnection];
    }
    
    return conn;
}

- (Connection *) getFreeConnection {
    
    if (CFArrayGetCount(freeConnections) <= 0) {
        CFSetApplyFunction(connections, isFreeConnection, freeConnections);
    }
    
    CFIndex count = CFArrayGetCount(freeConnections);
    assert(count > 0);
    
    Connection * fConn = CFArrayGetValueAtIndex(freeConnections, count-1);
    CFArrayRemoveValueAtIndex(freeConnections, count-1);
    assert(fConn != NULL);
    
    return fConn;
}

void isFreeConnection(const void *value, void *context) {
    
    Connection * conn = (__bridge Connection *)value;
    CFMutableArrayRef fConns = context;
    
    if (conn.isFree) {
        CFArrayAppendValue(fConns, (__bridge const void *)(conn));
    }
}

- (CFRunLoopRef) getNewRunLoop {
    
    return nil;
}

@end

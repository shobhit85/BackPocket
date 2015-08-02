//
//  Connection.h
//
//  Created by Shobhit Agarwal on 1/6/13.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

@interface Connection : NSObject {

    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
}

@property CFReadStreamRef readStream;
@property CFWriteStreamRef writeStream;
@property NSMutableData *dataRecieved;

@property BOOL isFree;

- (id)initWithIp:(const char *)ipAddress andPort:(int)port;

- (BOOL) sendData:(NSData *)data;

- (BOOL) waitForResult;

- (NSData *) getResultBytes;

- (void) close;

- (BOOL) isAlive;

- (BOOL) isAvailable;

@end

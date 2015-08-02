//
//  Connection.m
//
//  Created by Shobhit Agarwal on 1/6/13.
//

#import "Connection.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <netdb.h>
#import <arpa/inet.h>

@implementation Connection {
    
    void *streambuffer;
}

@synthesize readStream;
@synthesize writeStream;
@synthesize isFree;
@synthesize dataRecieved;

const int CHUNKSIZE = 100;

- (void) close {
    if (readStream != NULL && writeStream != NULL) {
        closeReadStream(readStream);
        CFRelease(writeStream);
    }
}

- (BOOL) isAlive {
    if (readStream != NULL && writeStream != NULL) {
        return TRUE;
    }
    return FALSE;
}

- (BOOL) isAvailable {
    return self.isFree;
}

- (id)initWithIp:(const char *)hostName andPort:(int)port {

    self = [super init];

    readStream = NULL;
    writeStream = NULL;

    CFStringRef hostStrRef = CFStringCreateWithCString(kCFAllocatorDefault, hostName, kCFStringEncodingASCII);

    CFStreamCreatePairWithSocketToHost(NULL, hostStrRef, port, &readStream, &writeStream);

    [self registerAndOpenStreams];

    // Allocate memory for receiving data
    streambuffer = CFAllocatorAllocate(NULL, CHUNKSIZE, 0);
    dataRecieved = [NSMutableData dataWithCapacity:CHUNKSIZE];
    
    return self;
}


- (void) registerAndOpenStreams {

    // Register and open read stream if not nil.
    if (readStream != NULL && writeStream != NULL) {
        
        CFStreamClientContext readContext = {0, (__bridge void *)(self), NULL, NULL, NULL};
        CFOptionFlags registeredEvents = kCFStreamEventHasBytesAvailable |
                                            kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
        
        if (CFReadStreamSetClient(readStream, registeredEvents, ReadDataCallBack, &readContext))
        {
            CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(),
                                            kCFRunLoopCommonModes);
        }
        
        // Check read stream open error.
        OSStatus macError = noErr;
        if (!CFReadStreamOpen(readStream)) {
            CFStreamError myErr = CFReadStreamGetError(readStream);
            if (myErr.error != 0) {
                // An error has occurred.
                if (myErr.domain == kCFStreamErrorDomainPOSIX) {
                    // Interpret myErr.error as a UNIX errno.
                    strerror(myErr.error);
                } else if (myErr.domain == kCFStreamErrorDomainMacOSStatus) {
                    macError = (OSStatus)myErr.error;
                }
            }
        }

        // Check write stream open error.
        if (!CFWriteStreamOpen(writeStream)) {
            CFStreamError myErr = CFWriteStreamGetError(writeStream);
            if (myErr.error != 0) {
                // An error has occurred.
                if (myErr.domain == kCFStreamErrorDomainPOSIX) {
                    // Interpret myErr.error as a UNIX errno.
                    strerror(myErr.error);
                } else if (myErr.domain == kCFStreamErrorDomainMacOSStatus) {
                    macError = (OSStatus)myErr.error;
                }
            }
        }
        
        if (macError != noErr) {
            NSLog(@"Error occurred while registering socket steams. error %s", [NSStringFromOSStatus(macError) cStringUsingEncoding:nil]);
            
        }
    }
}

/* To send data using write stream */
- (BOOL) sendData:(NSData *)data {
    
    self.isFree = FALSE;
    BOOL done = FALSE;
    CFIndex buflen = [data length];
    void *buf = CFAllocatorAllocate(NULL, buflen, 0);
    memcpy(buf, [data bytes], buflen);
    
    while (!done) {
        CFIndex bytesWritten = CFWriteStreamWrite(writeStream, buf, (CFIndex)buflen);
        if (bytesWritten < 0) {
            CFStreamError error = CFWriteStreamGetError(writeStream);
            reportError(error);
        } else if (bytesWritten == 0) {
            if (CFWriteStreamGetStatus(writeStream) == kCFStreamStatusAtEnd) {
                done = TRUE;
            }
        } else if (bytesWritten != buflen) {
            // Determine how much has been written and adjust the buffer
            buflen = buflen - bytesWritten;
            memmove(buf, buf + bytesWritten, buflen);
            
            // Figure out what went wrong with the write stream
            CFStreamError error = CFWriteStreamGetError(writeStream);
            reportError(error);
            
        } else {
            done = TRUE;
        }
    }
    
    free(buf);
    return done;
}

- (BOOL) waitForResult
{
    self.isFree = FALSE;
    //Listen on socket for some data with a timeeout.
    
    while (!CFReadStreamHasBytesAvailable(readStream)) {
        [NSThread sleepForTimeInterval:0.100];
    }
    
    UInt8 buf[100];
    CFIndex bytesRead = 0;
    
    while ( CFReadStreamHasBytesAvailable(readStream) && (bytesRead = CFReadStreamRead(readStream, buf, sizeof(buf))) > 0) {
        
        [self.dataRecieved appendBytes:buf length:bytesRead];
    }

    if ([dataRecieved length] > 0) {
        return TRUE;
    }
    return FALSE;
}

- (NSData *) getResultBytes
{
    NSData *responseData = [NSData dataWithBytes:[dataRecieved bytes] length:[dataRecieved length]];
    self.isFree = TRUE;
    return responseData;
}


/* Callback for reading data from a connection socket */
void ReadDataCallBack(CFReadStreamRef stream, CFStreamEventType event, void *copyToData) {
    
    switch(event) {
        case kCFStreamEventHasBytesAvailable:
        {
            UInt8 buf[100];
            CFIndex bytesRead = 0;
            
            while ( CFReadStreamHasBytesAvailable(stream) && (bytesRead = CFReadStreamRead(stream, buf, sizeof(buf))) > 0) {
                
                Connection *self = (Connection *)CFBridgingRelease(copyToData);
                
                [self.dataRecieved appendBytes:buf length:bytesRead];
            }
            
            // It is safe to ignore a value of bytesRead that is less than or
            // equal to zero because these cases will generate other events.
        }
            break;
        case kCFStreamEventErrorOccurred:
        {
            CFStreamError error = CFReadStreamGetError(stream);
            reportError(error);
            // Don't close it
            // closeReadStream(stream);
            // Find a way to let stream sleep and not consume resources.
        }
            break;
        case kCFStreamEventEndEncountered:
            reportCompletion();
            // Don't close it
            // closeReadStream(stream);
            // Find a way to let stream sleep and not consume resources.
            break;
        default:
            return;
    }
}

void closeReadStream (CFReadStreamRef stream) {
    CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(),
                                      kCFRunLoopCommonModes);
    CFReadStreamClose(stream);
    CFRelease(stream);
}

void reportCompletion() {
    NSLog(@"Finished reading the data from the socket in the ReadDataCallBack");
}

void reportError(CFStreamError error) {
    
    // Log the stream error.
    if (error.domain == kCFStreamErrorDomainNetServices) {
        NSLog(@"NetServices Error: %d, Error code can be interpreted using CFNetServices.h.", error.error);
    } else if (error.domain == kCFStreamErrorDomainMacOSStatus) {
        OSStatus macError = (OSStatus)error.error;
        NSLog(@"OS error: %d, CFStream.h says error code is to be interpreted using MacTypes.h.", macError);
    } else if (error.domain == kCFStreamErrorDomainPOSIX) {
        NSLog(@"POSIX error domain, Error code can be interpreted using sys/errno.h.");
    }
}

NSString *NSStringFromOSStatus(OSStatus errCode)
{
    if (errCode == noErr)
        return @"noErr";
    char message[5] = {0};
    *(UInt32*) message = CFSwapInt32HostToBig(errCode);
    return [NSString stringWithCString:message encoding:NSASCIIStringEncoding];
}

@end

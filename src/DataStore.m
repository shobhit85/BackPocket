//
//  Region.m
//
//  Created by Shobhit Agarwal on 1/3/13.
//

#import "DataStore.h"

#ifdef GOOGLE_PROTOBUF_MESSAGE_H__

#import <google>
#endif

@implementation DataStore

@synthesize abstractMap;
@synthesize connectionPool;
@synthesize size;
@synthesize name;


- (id) initWithPool:(Pool *)pool name:(NSString *)regionName
{
    if ((self = [super init])) {
        abstractMap = [[AbstractDataStoreMap alloc] init];
        self.connectionPool = pool;
        self.name = regionName;
        self.size = @(0);
        self.serializer = [[DefaultPListObjectSerializer alloc] init];
    }
    return self;
}

- (NSObject *) get:(NSObject *)key
{
    
    NSObject *value = nil;
    
    if (abstractMap != nil) {
        value = [abstractMap getValueForKey:(id)key];
    }

    // Get the value from server if not in local cache
    if (value == nil) {
        
        Message *message = [Message getNewMessage:1 for:self.name withKey:key andValue:nil];
        
        NSData *data = [Message serializeMessageNativelyWithPropertyList:message using:self.serializer];
        Connection *conn = [connectionPool getConnection];

        // Send message and wait for reply.
        if ([conn sendData:data]) {
            [conn waitForResult];
            NSData *result = [conn getResultBytes];
            
            // Deserilize the result.
            Message *replyMessage = (Message *)[Message deserializeMessageNativelyWithPropertyList:result using:self.serializer];
            value = [replyMessage getValue];
        }
    
        // Update local map.
        [self put:value forKey:key];
        self.size = @([size intValue] + 1);
    }
    return value;
}

- (void) put:(NSObject *)value forKey:(NSObject *)key
{
    
    if (abstractMap != NULL) {
        [abstractMap addValue:value toKey:key];
    }

    // Send the value to server too after updating local cache
    if (key != nil) {
        
        Message *message = [Message getNewMessage:2 for:self.name withKey:key andValue:value];

        // Serialize the message.
        NSData *data = [Message serializeMessageNativelyWithPropertyList:message using:self.serializer];
        
        Connection *conn = [connectionPool getConnection];
        
        // Send message and wait for reply.
        if ([conn sendData:data]) {
            [conn waitForResult];
            NSData *result = [conn getResultBytes];
            
            Message *replyMessage = (Message *)[Message deserializeMessageNativelyWithPropertyList:result using:self.serializer];
            NSString *resultStr =  [replyMessage getError];
            if ([resultStr compare:@"FALSE"]) {
                // server operation failed which is not expected at all.
                // Log appropriate severe message.
                NSLog(resultStr, nil);
                // If connection is down, Persist the operartion in a queue
                // and reapply later in same order as generated.
                // TODO: implement above functionality using core data.
            }
        }
        
        // Update local map.
        self.size = @([size intValue] + 1);
    }
}

- (NSObject *) remove: (NSObject *)key
{
    
    NSObject *value = nil;
    
    if (abstractMap != nil) {
        value = [abstractMap removeValueForKey:(id)key];
    }
    
    // Remove from server also.
    if (key != nil) {
        
        Message *message = [Message getNewMessage:2 for:self.name withKey:key andValue:value];

        NSData *data = [Message serializeMessageNativelyWithPropertyList:message using:self.serializer];
        Connection *conn = [connectionPool getConnection];
        
        // Send message and wait for reply.
        if ([conn sendData:data]) {
            [conn waitForResult];
            NSData *result = [conn getResultBytes];
            
            Message *replyMessage = (Message *)[Message deserializeMessageNativelyWithPropertyList:result using:self.serializer];
            NSString *resultStr =  [replyMessage getError];
            if (![resultStr compare:@"FALSE"]) {
                // server does not have the key
                // Log appropriate message.
                NSLog(resultStr, nil);
            }
        }
        
        // Update local map.
        self.size = @([size intValue] - 1);
    }
    return value;
}

- (NSInteger) getSize
{
    int s = [self.size intValue];
    return [NSNumber numberWithInt:s];
}

- (void) putAll: (NSDictionary *)keyValues
{
    
    
}

- (NSDictionary *) getAll
{
    return nil;
}

@end


    
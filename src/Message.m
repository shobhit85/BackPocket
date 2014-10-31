//
//  GetRequestMessage.m
//
//  Created by Shobhit Agarwal on 1/27/13.
//

#import "Message.h"

@implementation Message

@synthesize error;
@synthesize op;


+ (Message *)getNewMessage:(int16_t)operation for:(NSString *)store withKey:(NSObject *)key andValue:(NSObject *)value {
    
    Message *message = [[Message alloc] init];
    message.dsName = store;
    message.op = operation;
    message.key = key;
    message.value = value;
    return message;
}

/*
 * Method to return serialized message data for sending
 * across wire for Java Server.
 *
 * Message format -> [OPCODE]+[KEY_LENGTH]+[KEY_BYTES]+[VALUE_LENGTH]+[VALUE_BYTES]+[ERROR_LENGTH]+[ERROR_BYTES]
 * Same sequence is used for reading bytes and constructing Message object back.
 *
 */
+ (NSData *) serializeMessageNativelyWithPropertyList:(Message *)message using:(id <ObjectSerializer>)serializer{
    
    NSMutableData *messageBytes = [[NSMutableData alloc] init];
    
    if (serializer) {
        int16_t opcode = message.self.op;
        
        // Write opcode
        [messageBytes appendBytes:&opcode length:sizeof(int16_t)];

        // Write data-store name
        NSData *storeNameBytes = [[message getDSName] dataUsingEncoding:NSUTF32StringEncoding];
        int16_t name_length = storeNameBytes.length;
        [messageBytes appendBytes:&name_length length:sizeof(int16_t)];
        [messageBytes appendData:storeNameBytes];
        

        // Write key
        NSData *keybytes;
        if ([message getKey]) {
            // Serialize if already not serialized
            if ([[[message getKey] class] isSubclassOfClass:[NSData class]]) {
                keybytes = (NSData *)[message getKey];
            } else {
                keybytes = [serializer serialize:[message getKey]];
            }
        }
        
        int16_t key_length = (keybytes) ? keybytes.length : 0;
        
        // Write key length
        [messageBytes appendBytes:&key_length length:sizeof(int16_t)];
        if (keybytes) {
            [messageBytes appendData:keybytes];
        }
        
        // Write value
        NSData *valbytes;
        if ([message getValue]) {
            // Serialize if already not serialized
            if ([[[message getKey] class] isSubclassOfClass:[NSData class]]) {
                valbytes = (NSData *)[message getValue];
            } else {
                valbytes = [serializer serialize:[message getValue]];
            }
        }
        
        int16_t value_length = (valbytes) ? valbytes.length : 0;
        // Write value length
        [messageBytes appendBytes:&value_length length:sizeof(int16_t)];
        if (valbytes) {
            [messageBytes appendData:valbytes];
        }
    }
    
    return [[NSData alloc] initWithBytes:[messageBytes bytes] length:[messageBytes length]];
}

+ (Message *) deserializeMessageNativelyWithPropertyList:(NSData *)data using:(id <ObjectSerializer>)serializer{
    
    Message *message = [[Message alloc] init];
    
    if (serializer) {
        
        int32_t offset = 0;
        // First 2 bytes for opcode.
        int16_t opcode = 0;
        [data getBytes:&opcode length:2];
        NSRange range;
        
        // Read data store name
        offset += sizeof(int16_t);
        range.location = offset;
        range.length = OFFSETTER; // name length.
        int32_t name_length;
        [data getBytes:&name_length range:range];
        
        offset += OFFSETTER;
        if (name_length > 0) {
            range.length = name_length;
            range.location = offset;
            NSData *bytes = [data subdataWithRange:range];
            message.self.dsName = [[NSString alloc] initWithData:bytes encoding:NSUTF8StringEncoding];
        }
        
        // Read key
        offset += name_length;
        range.location = offset;
        range.length = OFFSETTER; // key length.
        int32_t key_length;
        [data getBytes:&key_length range:range];
        
        offset += OFFSETTER;
        if (key_length > 0) {
            range.length = key_length;
            range.location = offset;
            message.self.key = [NSData dataWithData:[data subdataWithRange:range]];
            //[data getBytes:(__bridge void *)(message.self.key) range:range];
            //message.self.key = [serializer deserialize:[data subdataWithRange:range]];
        }
        
        // Read value
        offset += key_length;
        range.location = offset;
        range.length = OFFSETTER; // value length.
        int32_t value_length;
        [data getBytes:&value_length range:range];
        
        offset += OFFSETTER;
        if (value_length > 0) {
            // Deserialize value bytes.
            range.length = value_length;
            range.location = offset;
            message.self.value = [NSData dataWithData:[data subdataWithRange:range]];
            //[data getBytes:(__bridge void *)(message.self.value) range:range];
            //message.self.value = [serializer deserialize:[data subdataWithRange:range]];
        }
        
        // Read error
        /* offset += value_length;
        range.location = offset;
        range.length = 2;
        int32_t error_length = [data subdataWithRange:range];
        
        offset += 4;
        if (error_length > 0) {
            // Deserialize value bytes.
            range.length = error_length;
            range.location = offset;
            message.self.error = (NSString *)[serializer deserialize:[data subdataWithRange:range]];
        }*/
    }

    return message;
}

@end

@implementation PutAllRequestMessage

@synthesize keyValues;

- (id)initWithCoder:(NSCoder *)decoder
{
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    // Not yet supported.
}

@end

@implementation PutAllReplyMessage

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.result = [decoder decodeObjectForKey:@"result"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_result forKey:@"result"];
}

@end
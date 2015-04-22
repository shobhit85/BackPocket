//
//  GetRequestMessage.h
//
//  Created by Shobhit Agarwal on 1/27/13.
//

#import <Foundation/Foundation.h>
#import "ObjectSerializer.h"
#import <objc/runtime.h>

#define OFFSETTER sizeof(int32_t)

@interface Message : NSObject

@property (assign, getter = getOpcode) int16_t op;
@property (retain, getter = getDSName) NSString *dsName;
@property (retain, getter = getKey) NSObject *key;
@property (retain, getter = getValue) NSObject *value;
@property (retain, getter = getError) NSString *error;

+ (NSData *) serializeMessageNativelyWithPropertyList:(Message *)message using:(id <ObjectSerializer>)serializer;

+ (Message *) deserializeMessageNativelyWithPropertyList:(NSData *)data using:(id <ObjectSerializer>)serializer;

+ (Message *) getNewMessage:(int16_t)op for:(NSString *)store withKey:(NSObject *)key andValue:(NSObject *)value;

@end


@interface PutAllRequestMessage : NSObject <NSCoding>

@property (retain, nonatomic) NSDictionary *keyValues;

@end

@interface PutAllReplyMessage : NSObject <NSCoding>

@property (retain, nonatomic) NSString *result;

@end

//
//  DefaultPListObjectSerializer.m
//
//  Created by Shobhit Agarwal on 10/13/13.
//

#import "DefaultPListObjectSerializer.h"

@implementation DefaultPListObjectSerializer

- (NSData *)serialize:(NSObject *)object {
    
    // Get NSDictionary from NSObject with properties.
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithUTF8String:property_getName(property)];
        id propertyValue = [object valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    
    free(properties);
    
    // convert NSDictionary to NSData using property list.
    NSString *error;
    
    if (outCount == 0) {
        [props setObject:object forKey:NSStringFromClass([object class])];
    }
    
    NSData *binary_data = [NSPropertyListSerialization dataFromPropertyList:(id)props
                                                                     format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
    
    
    if (error) {
        NSLog(error, nil);
    }

    return binary_data;
}

- (NSObject *)deserialize:(NSData *)bytes {
    
    NSError *error;
    NSDictionary *props = [NSPropertyListSerialization propertyListWithData:bytes options:NULL format:NSPropertyListBinaryFormat_v1_0 error:&error];
    
    if (error) {
        NSLog([error localizedDescription], nil);
    }
    
    NSObject *object = [[NSObject alloc] init];
    
    // Construct object from plist.
    [props enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [object setValue:obj forKey:(NSString *)key];
    }];
    
    return object;
}

@end

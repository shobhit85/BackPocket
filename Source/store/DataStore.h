//
//  Region.h
//
//  Created by Shobhit Agarwal on 1/3/13.
//

#import <Foundation/Foundation.h>
#import "AbstractDataStoreMap.h"
#import "DefaultPListObjectSerializer.h"
#import "Message.h"
#import "Pool.h"

@interface DataStore : NSObject {
    NSNumber *size;
    NSString *name;
    Pool *connectionPool;
    AbstractDataStoreMap *abstractMap;
}

@property (copy, getter = getName) NSString *name;
@property (atomic, retain, readwrite) AbstractDataStoreMap *abstractMap;
@property (nonatomic, readwrite) Pool *connectionPool;
@property (copy) NSNumber *size;

@property id<ObjectSerializer> serializer;


- (id) initWithPool:(Pool *)pool name:(NSString *)regionName;

- (NSObject *) get: (NSObject *)key;

- (void) put:(NSObject *)value forKey:(NSObject *)key;

- (NSObject *) remove: (NSObject *)key;

- (void) putAll: (NSMapTable *)values;

- (NSMapTable *) getAll;

- (NSInteger) getSize;

@end

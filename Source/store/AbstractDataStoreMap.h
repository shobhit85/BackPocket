//
//  AbstractRegionMap.h
//
//  Created by Shobhit Agarwal on 1/22/13.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#define DEFAULT_CACHE_SIZE 1000

@class DSValue;

@interface AbstractDataStoreMap : NSObject
{
    CFMutableDictionaryRef map;
    DSValue *first;
    DSValue *last;
    int32_t size;
}

@property (atomic, readonly) CFMutableDictionaryRef map;

- (id) initWithSize:(int)maxSize;

- (id) initWithKeyCB:(CFDictionaryKeyCallBacks)kcb andWithValueCB:(CFDictionaryValueCallBacks)vcb;

- (BOOL) addValue:(id)value toKey:(id)key;

- (id) getValueForKey:(id)key;

- (id) removeValueForKey:(id)key;

- (NSInteger) getSize;

- (void) clear;

@end

@interface DSValue : NSObject <NSCoding>

@property (retain, nonatomic) NSString *lastAccessTime;
@property (retain, nonatomic) NSObject *value;
@property (retain, atomic) NSObject *key;

@property (retain, nonatomic) DSValue *prev;
@property (retain, nonatomic) DSValue *next;

-(id) initWithValue:(NSObject *)val andKey:(NSObject *)k;

@end

NSString *GFGenerateSystemTimeStampAsString(void);
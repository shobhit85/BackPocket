//
//  AbstractRegionMap.m
//
//  Created by Shobhit Agarwal on 1/22/13.
//
#import "AbstractDataStoreMap.h"


@implementation AbstractDataStoreMap

@synthesize map;

- (id) init
{
    map = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return self;
}

- (id) initWithSize:(int)maxSize
{
    map = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    size = maxSize;
    return self;
}

- (id) initWithKeyCB:(CFDictionaryKeyCallBacks)kcb andWithValueCB:(CFDictionaryValueCallBacks)vcb
{
    map = CFDictionaryCreateMutable(NULL, 0, &kcb, &vcb);
    size = DEFAULT_CACHE_SIZE;
    return self;
}


- (BOOL) addValue:(id)value toKey:(id)key
{
    if (map != nil && key != nil) {
        
        // Get old RegionValue available and update it.
        DSValue *rValue = CFDictionaryGetValue(map, CFBridgingRetain(key));
        
        // Otherwise create new one.
        if (rValue == NULL) {
            rValue = [[DSValue alloc] initWithValue:value andKey:key];
            CFDictionaryAddValue(map, CFBridgingRetain(key), CFBridgingRetain(rValue));
        } else {
            rValue.value = value;
            rValue.lastAccessTime = GFGenerateSystemTimeStampAsString();
            CFDictionarySetValue(map, CFBridgingRetain(key), CFBridgingRetain(rValue));
        }
        
        
        if (first == nil) {
            first = rValue;
            last = first;
        } else {
        
            rValue.prev = nil;
            rValue.next = first;
            first = rValue;
        }
        
        // If LRU limit is reached flush the last element.
        if (CFDictionaryGetCount(map) == size) {
            DSValue * rvalue = last;
            last = rvalue.prev;
            rvalue.next = nil;
            CFRelease(CFBridgingRetain(rvalue));
        }
        
        return TRUE;
    }
    
    return FALSE;
}

- (id) getValueForKey:(id)key
{
    DSValue *rValue = CFDictionaryGetValue(map, CFBridgingRetain(key));
    
    if (rValue != NULL) {
        rValue.lastAccessTime = GFGenerateSystemTimeStampAsString();

        // Move the value to bottom of link list.
        DSValue *prev = rValue.prev;
        DSValue *next = rValue.next;
    
        if (prev != NULL) prev.next = rValue.next;
        if (next != NULL) next.prev = rValue.prev;

        rValue.prev = NULL;
        rValue.next = first;
        first = rValue;
    }
    return rValue.value;
}

- (id) removeValueForKey:(id)key
{
    DSValue *rValue = CFDictionaryGetValue(map, &key);
    
    if (rValue != NULL) {
        rValue.lastAccessTime = GFGenerateSystemTimeStampAsString();
        
        // Move the value to bottom of link list.
        DSValue *prev = rValue.prev;
        DSValue *next = rValue.next;
        
        if (prev != NULL) prev.next = rValue.next;
        if (next != NULL) next.prev = rValue.prev;
        
        rValue.prev = NULL;
        rValue.next = NULL;
    }

    CFDictionaryRemoveValue(map, &key);
    
    return rValue;
}

- (NSInteger) getSize
{
    return CFDictionaryGetCount(map);
}

- (void) clear
{
    CFDictionaryRemoveAllValues(map);
    CFBridgingRelease(map);
    last = nil;
    first = nil;
}

@end


/*
 * Internal value structure which is part of LRU
 * linked list constructed in parallel to the map.
 */
@implementation DSValue

@synthesize key;
@synthesize value;
@synthesize lastAccessTime;
@synthesize prev;
@synthesize next;

-(id) initWithValue:(NSObject *)val andKey:(NSObject *)k {
    
    if (self = [super init]) {
        self.lastAccessTime = GFGenerateSystemTimeStampAsString();
        self.value = val;
        self.key = k;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.lastAccessTime = [decoder decodeObjectForKey:@"lastAccessTime"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.value = [decoder decodeObjectForKey:@"value"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:lastAccessTime forKey:@"lastAccessTime"];
    [encoder encodeObject:key forKey:@"key"];
    [encoder encodeObject:value forKey:@"value"];
}

@end

/*
 * Method to return current timestamp as a string.
 */

NSString *GFGenerateSystemTimeStampAsString() {
    
    NSDate *past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970];
    NSString *unixTime = [[NSString alloc] initWithFormat:@"%0.0f", oldTime];
    return unixTime;
}

DSValue *GFGetInternalRegionValue(NSObject *value, NSObject *key) {
    
    DSValue *rValue = [[DSValue alloc] initWithValue:value andKey:key];
    return rValue;
}

//
//  NSObject+MFDictionaryAdapter.m
//  MFSimpleDatabase
//
//  Created by Latermoon on 12-9-16.
//  Copyright (c) 2012 Latermoon. All rights reserved.
//

#import "NSObject+MFDictionaryAdapter.h"
#import "MFDictionaryAccessor.h"

@implementation NSObject (MFDictionaryAdapter)

#pragma mark - Wrap for objectForKey:aKey
- (id)objectForKey:(NSString *)aKey defaultValue:(id)value
{
    /* 协议检查 */
    if ([self conformsToProtocol:@protocol(MFDictionaryAccessor)]) {
        id obj = [(id<MFDictionaryAccessor>)self objectForKey:(id)aKey];
        return obj != nil ? obj : value;
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        id obj = [(NSDictionary *)self objectForKey:aKey];
        return obj != nil ? obj : value;
    } else {
        NSLog(@"Error, %@ not conformsToProtocol MFDictionaryAccessor", self);
        return nil;
    }
}

- (NSString *)stringForKey:(NSString *)aKey defaultValue:(NSString *)value
{
    return (NSString *)[self objectForKey:aKey defaultValue:value];
}

- (NSArray *)arrayForKey:(NSString *)aKey defaultValue:(NSArray *)value
{
    return (NSArray *)[self objectForKey:aKey defaultValue:value];
}

- (NSDictionary *)dictionaryForKey:(NSString *)aKey defaultValue:(NSDictionary *)value
{
    return (NSDictionary *)[self objectForKey:aKey defaultValue:value];
}

- (NSData *)dataForKey:(NSString *)aKey defaultValue:(NSData *)value
{
    return (NSData *)[self objectForKey:aKey defaultValue:value];
}

- (NSNumber *)numberForKey:(NSString *)aKey defaultValue:(NSNumber *)value
{
    return (NSNumber *)[self objectForKey:aKey defaultValue:value];
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)aKey defaultValue:(NSUInteger)value
{
    id obj = [self objectForKey:aKey defaultValue:nil];
    return obj != nil && [obj respondsToSelector:@selector(unsignedIntegerValue)] ? [obj unsignedIntegerValue] : value;
}

- (NSInteger)integerForKey:(NSString *)aKey defaultValue:(NSInteger)value
{
    id obj = [self objectForKey:aKey defaultValue:nil];
    return obj != nil && [obj respondsToSelector:@selector(integerValue)] ? [obj integerValue] : value;
}

- (float)floatForKey:(NSString *)aKey defaultValue:(float)value
{
    id obj = [self objectForKey:aKey defaultValue:nil];
    return obj != nil && [obj respondsToSelector:@selector(floatValue)] ? [obj floatValue] : value;
}

- (double)doubleForKey:(NSString *)aKey defaultValue:(double)value
{
    id obj = [self objectForKey:aKey defaultValue:nil];
    return obj != nil && [obj respondsToSelector:@selector(doubleValue)] ? [obj doubleValue] : value;
}

- (long long)longLongValueForKey:(NSString *)aKey defaultValue:(long long)value
{
    id obj = [self objectForKey:aKey defaultValue:nil];
    return obj != nil && [obj respondsToSelector:@selector(longLongValue)] ? [obj longLongValue] : value;
}

- (BOOL)boolForKey:(NSString *)aKey defaultValue:(BOOL)value
{
    id obj = [self objectForKey:aKey defaultValue:nil];
    return obj != nil && [obj respondsToSelector:@selector(boolValue)] ? [obj boolValue] : value;
}

- (NSDate *)dateForKey:(NSString *)aKey defaultValue:(NSDate *)value
{
    return (NSDate *)[self objectForKey:aKey defaultValue:value];
}

#pragma mark - Wrap for setObject:value forKey:aKey
- (void)setObjectSafe:(id)value forKey:(id)aKey
{
    if (!value || !aKey) {
//        DLog(DT_all, @"nil value(%@) or key(%@)", value, aKey);
        return;
    }
    if ([self conformsToProtocol:@protocol(MFDictionaryAccessor)]) {
        [(id<MFDictionaryAccessor>)self setObject:(id)value forKey:(id)aKey];
    } else if ([self isKindOfClass:[NSMutableDictionary class]]) {
        [(NSMutableDictionary *)self setObject:(id)value forKey:(id)aKey];
    } else {
        NSLog(@"Error, %@ not conformsToProtocol MFDictionaryAccessor", self);
    }
}

- (void)setString:(NSString *)value forKey:(NSString *)aKey
{
    [self setObjectSafe:value forKey:aKey];
}

- (void)setNumber:(NSNumber *)value forKey:(NSString *)aKey
{
    [self setObjectSafe:value forKey:aKey];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)aKey
{
    [self setNumber:[NSNumber numberWithInt:value] forKey:aKey];
}

- (void)setFloat:(float)value forKey:(NSString *)aKey
{
    [self setNumber:[NSNumber numberWithFloat:value] forKey:aKey];
}

- (void)setDouble:(double)value forKey:(NSString *)aKey
{
    [self setNumber:[NSNumber numberWithDouble:value] forKey:aKey];
}

- (void)setLongLongValue:(long long)value forKey:(NSString *)aKey
{
    [self setNumber:[NSNumber numberWithLongLong:value] forKey:aKey];
}

- (void)setBool:(BOOL)value forKey:(NSString *)aKey
{
    [self setNumber:[NSNumber numberWithBool:value] forKey:aKey];
}

@end

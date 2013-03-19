//
//  MFDbRow+DictionaryAdapter.m
//  MFSimpleDatabase
//
//  Created by Latermoon on 13-3-19.
//  Copyright (c) 2013年 Latermoon.com. All rights reserved.
//

#import "MFDbRow+DictionaryAdapter.h"

@implementation MFDbRow (DictionaryAdapter)

#pragma mark - Wrap for objectForKey:aKey
- (id)objectForKey:(NSString *)aKey defaultValue:(id)value
{
    id obj = [self objectForKey:(id)aKey];
    return obj != nil ? obj : value;
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
    id origin = [self objectForKey:aKey defaultValue:value];
    if ([origin isKindOfClass:[NSDate class]]) {
        return origin;
    } else if ([origin isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[origin doubleValue]];
    } else {
        return value;
    }
}

#pragma mark - Wrap for setObject:value forKey:aKey
- (void)setObjectSafe:(id)value forKey:(id)aKey
{
    if (!value || !aKey) {
        return;
    }
    [self setObject:(id)value forKey:(id)aKey];
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

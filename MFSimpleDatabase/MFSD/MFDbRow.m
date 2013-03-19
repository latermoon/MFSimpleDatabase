//
//  MFDbRow.m
//  MFSimpleDatabase
//
//  Created by Latermoon on 12-9-9.
//
//

#import "MFDbRow.h"

@implementation MFDbRow
@synthesize dataDict;

#pragma mark - Init
- (MFDbRow *)initWithDictionary:(NSDictionary *)aDataDict
{
    self = [super init];
    if (self) {
        dataDict = [aDataDict retain];
    }
    return self;
}

- (void)dealloc
{
    [dataDict release];
    [super dealloc];
}

#pragma mark -
- (id)objectForKey:(id)aKey
{
    // 将数据库中的NSNull
    id obj = [dataDict objectForKey:aKey];
    if (obj && [obj isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return obj;
    }
}

- (void)setObject:(id)value forKey:(id)aKey
{
    if (value == nil) {
        NSLog(@"Warning, setObject:nil forKey:%@", aKey);
        return;
    }
    [[self mutableDict] setObject:value forKey:aKey];
}

- (void)removeObjectForKey:(NSString *)aKey
{
    [[self mutableDict] removeObjectForKey:aKey];
}

#pragma mark - Overide
- (NSString *)description
{
    return [dataDict description];
}

// 如果dataDict本身是NSMutableDictionary
- (NSMutableDictionary *)mutableDict
{
    return (NSMutableDictionary *)dataDict;
}

@end

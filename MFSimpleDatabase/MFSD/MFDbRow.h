//
//  MFDbRow.h
//  MFSimpleDatabase
//
//  Created by Latermoon on 12-9-9.
//
//

#import <Foundation/Foundation.h>

/**
 * 表示数据库中的一行，相比NSDictionary，MFDbRow主要的作用是数据类型转换
 * MFDbRow *row = [userColl findOne:@"momoid='100422'"];
 * NSString *momoid = [row stringForKey:@"momoid"];
 */
@interface MFDbRow : NSObject
{
    NSDictionary *dataDict;
}

@property (readonly) NSDictionary *dataDict;

#pragma mark - Init
- (MFDbRow *)initWithDictionary:(NSDictionary *)aDataDict;

#pragma mark - MFDictionaryAccessor
- (id)objectForKey:(id)aKey;
- (void)setObject:(id)value forKey:(id)aKey;
- (void)removeObjectForKey:(NSString *)aKey;

#pragma mark - Overide
- (NSString *)description;

@end

#pragma mark - Private
@interface MFDbRow (Private)

// 如果dataDict本身是NSMutableDictionary
- (NSMutableDictionary *)mutableDict;

@end

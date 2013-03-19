//
//  MFDbCollection.h
//  MFSimpleDatabase
//
//  Created by Latermoon on 12-9-9.
//
//

#import <Foundation/Foundation.h>

// MFDbList本质上是数组
#define MFDbList NSArray

@class FMDatabase;
@protocol MFDatabase;
@class MFSimpleDatabase;
@class MFDbRow;

/**
 * 包装对一个数据表的增删改查操作，无需使用SQL语句
 * MFDbCollection *userColl = [mfdb collection:@"user"];
 * MFDbRow *row = [userColl findOne:@"momoid='100422'"];
 * NSString *name = [row stringForColumn:@"name"];
 */
@interface MFDbCollection : NSObject
{
    MFSimpleDatabase *database;
    NSString *tableName;
}

#pragma mark - Properties
@property (readonly) MFSimpleDatabase *database;
// 当前表名
@property (readonly) NSString *tableName;

#pragma mark - Init
+ (MFDbCollection *)collectionWithDatabase:(MFSimpleDatabase *)_database table:(NSString *)_tableName;
- (MFDbCollection *)initWithDatabase:(MFSimpleDatabase *)_database table:(NSString *)_tableName;

- (BOOL)exists;

#pragma mark - findOne
// 查找数据库中的一行数据
- (MFDbRow *)findOne:(NSString *)query;
- (MFDbRow *)findOne:(NSString *)query fields:(NSArray *)fields;

#pragma mark  find
// find的参数都可以为nil或者-1表示默认值，或不指定
- (MFDbList *)find;
- (MFDbList *)find:(NSString *)query;
- (MFDbList *)find:(NSString *)query fields:(NSArray *)fields;
- (MFDbList *)find:(NSString *)query fields:(NSArray *)fields orderBy:(NSString *)order;
- (MFDbList *)find:(NSString *)query fields:(NSArray *)fields orderBy:(NSString *)order skip:(NSInteger)index count:(NSInteger)limit;
// 获取数据行数, key是要统计的字段，指定的话可以节省资源
- (NSInteger)findCount:(NSString *)query withKey:(NSString *)key;
// 实现数据库的in操作
- (NSDictionary *)findByKey:(NSString *)key andValues:(NSArray *)values fields:(NSArray *)fields;

#pragma mark - Insert
- (BOOL)insert:(NSDictionary *)dictObj;
// upsert = update or insert，要求表中带有UniqueIndex，并且存在dictObj里
- (BOOL)upsert:(NSDictionary *)dictObj;
- (NSUInteger)batchUpsert:(NSArray *)dictObjArray;

#pragma mark - Update
- (BOOL)update:(NSString *)query row:(NSDictionary *)dictObj;
- (BOOL)updateForKey:(NSString *)key withValue:(id)value row:(NSDictionary *)dictObj;

#pragma mark - Delete
// 删除全表数据
- (BOOL)delete;
// 自己构建更丰富的删除条件 delete:@"momoid='100422' or momoid='100428'"
- (BOOL)delete:(NSString *)query;
// 根据指定字段删除, 比如deleteForKey:@"momoid" withValue:@"100422"
- (BOOL)deleteForKey:(NSString *)key withValue:(id)value;

#pragma mark - Drop
// 删除某个表
- (BOOL)drop:(NSString *)aTableName;

@end

#pragma mark - Private Method
@interface MFDbCollection (Private)

#pragma mark - INSERT/REPLACE INTO
- (NSUInteger)insertOrReplaceUseUnionSQL:(NSString *)insertOrReplaceString rows:(NSArray *)dictObjArray;
- (NSUInteger)insertOrReplaceUseMultiSQL:(NSString *)insertOrReplaceString rows:(NSArray *)dictObjArray;
@end

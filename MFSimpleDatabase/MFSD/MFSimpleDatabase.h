//
//  MFSimpleDatabase.h
//  MFSimpleDatabase
//
//  Created by Latermoon on 12-9-9.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseQueue.h"
#import "MFDbCollection.h"
#import "MFDbRow.h"

/**
 * 对FMDatabase进行封装，提供线程安全的数据库操作
 * 简化数据库操作，让数据库开发减少依赖SQL知识
 MFDbRow *row = [userColl findOne:@"momoid='100422' and remoteid='100428'"];
 MFDbList *list = [userColl find:@"momoid=100422" sort:@"loc_time" asc:YES];
 MFDbList *list = [userColl findAll];
 [userColl insert:userObj];
 [userColl update:userObj forKey:@"momoid" withValue:@"100422"];
 [userColl updateOrInsert:userObj forKey:@"momoid" withValue:@"100422"];
 [userColl deleteForKey:@"momoid" withValue:@"100422"];
 */
@interface MFSimpleDatabase : NSObject
{
    // 真正操作数据库的对象
    FMDatabaseQueue *innerDb;
    // 对collection:tableName方法进行缓存
    NSMutableDictionary *collCache;
    // 当前打开事务的计数器
    NSUInteger transactionCounter;
}

// 需要使用原生SQL语句时可以直接调用innerDb
@property (readonly) FMDatabaseQueue *innerDb;

#pragma mark - Init
+ (MFSimpleDatabase *)databaseWithPath:(NSString *)path;
- (MFSimpleDatabase *)initWithPath:(NSString *)path;

#pragma mark - Transaction
- (void)beginTransaction;
- (void)rollback;
- (void)commit;

#pragma mark - Collection
// 获取数据库中的一个表
- (MFDbCollection *)collection:(NSString *)tableName;
- (NSError *)lastError;

#pragma mark - Query
- (MFDbList *)executeQuery:(NSString *)sql;
- (MFDbList *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
- (MFDbList *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;

#pragma mark - Update
- (BOOL)executeUpdate:(NSString *)sql;
- (BOOL)executeUpdate:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
- (BOOL)executeUpdate:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;

@end

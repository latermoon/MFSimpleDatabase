//
//  MFDbCollection.m
//  MFSimpleDatabase
//
//  Created by Latermoon on 12-9-9.
//
//

#import "MFDbCollection.h"
#import "MFSimpleDatabase.h"
#import "FMDatabase.h"

@implementation MFDbCollection
@synthesize database, tableName;

#pragma mark
#pragma mark Init
+ (MFDbCollection *)collectionWithDatabase:(MFSimpleDatabase *)_database table:(NSString *)_tableName
{
    return [[[MFDbCollection alloc] initWithDatabase:_database table:_tableName] autorelease];
}

- (MFDbCollection *)initWithDatabase:(MFSimpleDatabase *)_database table:(NSString *)_tableName
{
    self = [super init];
    if (self) {
        database = [_database retain];
        tableName = [_tableName retain];
    }
    return self;
}

- (void)dealloc
{
    [database release];
    [tableName release];
    [super dealloc];
}

- (BOOL)exists
{
    NSString *sql = @"select count(*) count from sqlite_master where name=?";
    MFDbList *result = [database executeQuery:sql withArgumentsInArray:[NSArray arrayWithObject:tableName]];
    if (result && [result count] > 0) {
        MFDbRow *row = [result objectAtIndex:0];
        return [row boolForKey:@"count" defaultValue:NO];
    } else {
        NSLog(@"Wraning... %@", tableName);
        return NO;
    }
}

#pragma mark
#pragma mark Query
- (MFDbRow *)findOne:(NSString *)query
{
    return [self findOne:query fields:nil];
}

- (MFDbRow *)findOne:(NSString *)query fields:(NSArray *)fields
{
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    [sqlbuf appendString:@"SELECT "];
    if (!fields || [fields count] == 0) {
        [sqlbuf appendString:@"*"];
    } else {
        [sqlbuf appendString:[fields componentsJoinedByString:@","]];
    }
    [sqlbuf appendString:@" FROM "];
    [sqlbuf appendString:tableName];
    [sqlbuf appendString:@" WHERE "];
    [sqlbuf appendString:query];
    [sqlbuf appendString:@" LIMIT 1"];
    NSString *sqlString = [sqlbuf description];
    
    MFDbList *result = [database executeQuery:sqlString];
    return [result count] > 0 ? (MFDbRow *)[result objectAtIndex:0] : nil;
}

- (MFDbList *)find
{
    return [self find:nil];
}

- (MFDbList *)find:(NSString *)query
{
    return [self find:query fields:nil];
}

- (MFDbList *)find:(NSString *)query fields:(NSArray *)fields
{
    return [self find:query fields:fields orderBy:nil];
}

- (MFDbList *)find:(NSString *)query fields:(NSArray *)fields orderBy:(NSString *)order
{
    return [self find:query fields:fields orderBy:order skip:-1 count:-1];
}

- (MFDbList *)find:(NSString *)query fields:(NSArray *)fields orderBy:(NSString *)order skip:(NSInteger)index count:(NSInteger)limit
{
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    [sqlbuf appendString:@"SELECT "];
    if (!fields || [fields count] == 0) {
        [sqlbuf appendString:@"*"];
    } else {
        [sqlbuf appendString:[fields componentsJoinedByString:@","]];
    }
    [sqlbuf appendString:@" FROM "];
    [sqlbuf appendString:tableName];
    if (query && [query length] > 0) {
        [sqlbuf appendString:@" WHERE "];
        [sqlbuf appendString:query];
    }
    if (order && [order length] > 0) {
        [sqlbuf appendString:@" ORDER BY "];
        [sqlbuf appendString:order];
    }
    if (limit > 0) {
        [sqlbuf appendString:@" LIMIT "];
        if (index >= 0) {
            [sqlbuf appendString:[[NSNumber numberWithInt:index] stringValue]];
            [sqlbuf appendString:@","];
        }
        [sqlbuf appendString:[[NSNumber numberWithInt:limit] stringValue]];
    }
    NSString *sqlString = [sqlbuf description];
    
    MFDbList *result = [database executeQuery:sqlString];
    return result;
}

- (NSInteger)findCount:(NSString *)query withKey:(NSString *)key
{
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    [sqlbuf appendString:@"SELECT COUNT("];
    if (key && [key length] > 0) {
        [sqlbuf appendString:key];
    } else {
        [sqlbuf appendString:@"*"];
    }
    [sqlbuf appendString:@") rowcount FROM "];
    [sqlbuf appendString:tableName];
    if (query && [query length] > 0) {
        [sqlbuf appendString:@" WHERE "];
        [sqlbuf appendString:query];
    }
    NSString *sqlString = [sqlbuf description];
    
    NSInteger rowCount = 0;
    MFDbList *result = [database executeQuery:sqlString];
    if (result && [result count] > 0) {
        MFDbRow *row = [result objectAtIndex:0];
        rowCount = [row integerForKey:@"rowcount" defaultValue:0];
    }
    return rowCount;
}

- (NSDictionary *)findByKey:(NSString *)key andValues:(NSArray *)values fields:(NSArray *)fields
{
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    [sqlbuf appendString:@"SELECT "];
    if (!fields || [fields count] == 0) {
        [sqlbuf appendString:@"*"];
    } else {
        [sqlbuf appendString:[fields componentsJoinedByString:@","]];
    }
    [sqlbuf appendString:@" FROM "];
    [sqlbuf appendString:tableName];
    // 构建where momoid in ('100422', '100428', '300000')
    if (key && values && [values count] > 0) {
        [sqlbuf appendString:@" WHERE "];
        [sqlbuf appendString:key];
        [sqlbuf appendString:@" IN ("];
        for (int i = 0; i < [values count]; i ++) {
            if (i > 0) {
                [sqlbuf appendString:@", "];
            }
            [sqlbuf appendString:@"'"];
            [sqlbuf appendString:[values objectAtIndex:i]];
            [sqlbuf appendString:@"'"];
        }
        [sqlbuf appendString:@")"];
    }
    NSString *sqlString = [sqlbuf description];
    
    MFDbList *result = [database executeQuery:sqlString];
    NSMutableDictionary *dictResult = [NSMutableDictionary dictionaryWithCapacity:[result count]];
    for (MFDbRow *row in result) {
        // key = momoid, value = 100428, 通过value重新构建dictionary
        NSString *value = [row stringForKey:key defaultValue:nil];
        if (value) {
            [dictResult setObject:row forKey:value];
        }
    }
    return dictResult;
}

#pragma mark
#pragma mark Insert
- (BOOL)insert:(NSDictionary *)dictObj
{
    return [self insertOrReplaceUseMultiSQL:@"INSERT" rows:[NSArray arrayWithObject:dictObj]] > 0;
}

- (BOOL)upsert:(NSDictionary *)dictObj
{
    return [self insertOrReplaceUseMultiSQL:@"REPLACE" rows:[NSArray arrayWithObject:dictObj]] > 0;
}

- (NSUInteger)batchUpsert:(NSArray *)dictObjArray
{
    return [self insertOrReplaceUseMultiSQL:@"REPLACE" rows:dictObjArray];
}

#pragma mark
#pragma mark Update
- (BOOL)update:(NSString *)query row:(NSDictionary *)dictObj
{
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    [sqlbuf appendString:@"UPDATE "];
    [sqlbuf appendString:tableName];
    [sqlbuf appendString:@" SET "];
    NSInteger appendCount = 0;
    for (NSString *field in [dictObj allKeys]) {
        if (appendCount > 0) {
            [sqlbuf appendString:@", "];
        }
        [sqlbuf appendString:field];
        [sqlbuf appendString:@"=:"];
        [sqlbuf appendString:field];
        appendCount ++;
    }
    [sqlbuf appendString:@" WHERE "];
    [sqlbuf appendString:query];
    NSString *sqlString = [sqlbuf description];
    
    __block BOOL success = NO;
    [[database innerDb] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sqlString withParameterDictionary:dictObj];
    }];
    return success;
}

- (BOOL)updateForKey:(NSString *)key withValue:(id)value row:(NSDictionary *)dictObj
{
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    [sqlbuf appendString:@"UPDATE "];
    [sqlbuf appendString:tableName];
    [sqlbuf appendString:@" SET "];
    NSInteger appendCount = 0;
    for (NSString *field in [dictObj allKeys]) {
        if (appendCount > 0) {
            [sqlbuf appendString:@", "];
        }
        [sqlbuf appendString:field];
        [sqlbuf appendString:@"=:"];
        [sqlbuf appendString:field];
        appendCount ++;
    }
    [sqlbuf appendString:@" WHERE "];
    [sqlbuf appendString:key];
    [sqlbuf appendString:@"=:"];
    [sqlbuf appendString:key];
    NSString *sqlString = [sqlbuf description];
    
    __block BOOL success = NO;
    [[database innerDb] inDatabase:^(FMDatabase *db) {
        // 构建新的NSDictionary
        NSMutableDictionary *mergeDictObj = [NSMutableDictionary dictionaryWithDictionary:dictObj];
        [mergeDictObj setValue:value forKey:key];
        success = [db executeUpdate:sqlString withParameterDictionary:mergeDictObj];
    }];
    return success;
}


#pragma mark
#pragma mark INSERT/REPLACE INTO

// 将 INSERT INTO 和 REPLACE INTO 合并重复代码
- (NSUInteger)insertOrReplaceUseUnionSQL:(NSString *)insertOrReplaceString rows:(NSArray *)dictObjArray
{
    NSArray *keys = [[dictObjArray objectAtIndex:0] allKeys];
    // 存放全部参数数据
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    // must be "INSERT" or "REPLACE"
    [sqlbuf appendString:insertOrReplaceString];
    [sqlbuf appendString:@" INTO "];
    [sqlbuf appendString:tableName];
    [sqlbuf appendString:@" ("];
    [sqlbuf appendString:[keys componentsJoinedByString:@","]];
    [sqlbuf appendString:@") "];
    
    // 构建 replace into bothFriends_tmp1(b_momoid, b_time) select :b_momoid1, :b_time1 as 'b_momoid' union select '100428' as 'b_momoid'
    // MySQL才支持 replace into table(column) values (value1), (value2), (value3)的形式
    NSUInteger rowIndex = 0; // 当前扫描到第几行
    for (NSDictionary *dictObj in dictObjArray) {
        if (rowIndex > 0) {
            [sqlbuf appendString:@" UNION "];
        }
        NSInteger appendCount = 0;
        [sqlbuf appendString:@" SELECT "];
        for (NSString *key in keys) {
            if (appendCount > 0) {
                [sqlbuf appendString:@", "];
            }
            [sqlbuf appendString:@":"];
            NSString *valueName = [key stringByAppendingFormat:@"%d", rowIndex];
            // 使用 :m_momoid_1, :m_momoid_2 这样的有序参数
            [sqlbuf appendString:valueName];
            // 将参数转存到总参数表里
            [allParams setObject:[dictObj objectForKey:key] forKey:valueName];
            appendCount ++;
        }
        [sqlbuf appendString:@" "];
        rowIndex ++;
    }
    
    NSString *sqlString = [sqlbuf description];
    
    __block BOOL success = NO;
    [[database innerDb] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sqlString withParameterDictionary:allParams];
    }];
    return success;
}

- (NSUInteger)insertOrReplaceUseMultiSQL:(NSString *)insertOrReplaceString rows:(NSArray *)dictObjArray
{
    if (dictObjArray.count > 0){
        NSArray *keys = [[dictObjArray objectAtIndex:0] allKeys];
        
        NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
        // must be "INSERT" or "REPLACE"
        [sqlbuf appendString:insertOrReplaceString];
        [sqlbuf appendString:@" INTO "];
        [sqlbuf appendString:tableName];
        [sqlbuf appendString:@" ("];
        [sqlbuf appendString:[keys componentsJoinedByString:@","]];
        [sqlbuf appendString:@") VALUES ("];
        
        NSInteger appendCount = 0;
        for (NSString *key in keys) {
            if (appendCount > 0) {
                [sqlbuf appendString:@", "];
            }
            [sqlbuf appendString:@":"];
            [sqlbuf appendString:key];
            appendCount ++;
        }
        [sqlbuf appendString:@")"];
        
        NSString *sqlString = [sqlbuf description];
        
        __block BOOL success = NO;
        [[database innerDb] inDatabase:^(FMDatabase *db) {
            for (NSDictionary *dict in dictObjArray) {
                success = [db executeUpdate:sqlString withParameterDictionary:dict];
            }
        }];
        return success;
        
    }
    
    return NO;
}


#pragma mark
#pragma mark Delete
- (BOOL)delete
{
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    [sqlbuf appendString:@"DELETE FROM "];
    [sqlbuf appendString:tableName];
    NSString *sqlString = [sqlbuf description];
    
    __block BOOL success = NO;
    [[database innerDb] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sqlString];
    }];
    return success;
}

- (BOOL)delete:(NSString *)query
{
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    [sqlbuf appendString:@"DELETE FROM "];
    [sqlbuf appendString:tableName];
    [sqlbuf appendString:@" WHERE "];
    [sqlbuf appendString:query];
    NSString *sqlString = [sqlbuf description];
    
    __block BOOL success = NO;
    [[database innerDb] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sqlString];
    }];
    return success;
}

- (BOOL)deleteForKey:(NSString *)key withValue:(id)value
{
    // 因为value的值是id，所以没有直接构建NSString *query调用上面的delete:query
    NSMutableString *sqlbuf = [NSMutableString stringWithCapacity:256];
    [sqlbuf appendString:@"DELETE FROM "];
    [sqlbuf appendString:tableName];
    [sqlbuf appendString:@" WHERE "];
    [sqlbuf appendString:key];
    // 因为下面使用executeUpdate:sql, ...，所以这里用=?而不是=:key，减少NSArray或NSDictionary的构建成本
    [sqlbuf appendString:@"=?"];
    NSString *sqlString = [sqlbuf description];
    
    __block BOOL success = NO;
    [[database innerDb] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sqlString, value];
    }];
    return success;
}

#pragma mark
#pragma mark Drop
- (BOOL)drop:(NSString *)aTableName
{
    NSString *sqlString = [NSString stringWithFormat:@"DROP TABLE %@", aTableName];
    __block BOOL success = NO;
    [[database innerDb] inDatabase:^(FMDatabase *db) {
        [db closeOpenResultSets];
        success = [db executeUpdate:sqlString];
    }];
    return success;
}


@end

//
//  MFSimpleDatabase.m
//  MFSimpleDatabase
//
//  Created by Latermoon on 12-9-9.
//
//

#import "MFSimpleDatabase.h"

@implementation MFSimpleDatabase
@synthesize innerDb;

#pragma mark
#pragma mark Init
+ (MFSimpleDatabase *)databaseWithPath:(NSString *)path
{
    return [[[MFSimpleDatabase alloc] initWithPath:path] autorelease];
}

- (MFSimpleDatabase *)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        innerDb = [[FMDatabaseQueue databaseQueueWithPath:path] retain];
        [innerDb inDatabase:^(FMDatabase *db) {
            // 如果需要详细的执行日志，可打开下面注释
            // [db setTraceExecution:YES];
            [db setLogsErrors:YES];
        }];
        collCache = [[NSMutableDictionary alloc] initWithCapacity:20];
		transationQueue = dispatch_queue_create([NSString stringWithFormat:@"mfdb.%@", path], NULL);
    }
    return self;
}

- (void)dealloc
{
    [collCache release];
    [innerDb close];
    [innerDb release];
	dispatch_release(transationQueue);
    [super dealloc];
}

#pragma mark - Transaction
- (void)inTransaction:(void (^)(MFSimpleDatabase *mfdb, BOOL *rollback))block
{
    
}

#pragma mark
#pragma mark Collection
- (MFDbCollection *)collection:(NSString *)tableName
{
    // 通过缓存减少重复创建
    MFDbCollection *coll = [collCache objectForKey:tableName];
    if (!coll) {
        coll = [MFDbCollection collectionWithDatabase:self table:tableName];
        [collCache setObject:coll forKey:tableName];
    }
    return coll;
}

- (NSError *)lastError
{
    __block NSError *err = nil;
    [innerDb inDatabase:^(FMDatabase *db) {
        err = [db lastError];
    }];
    return err;
}

#pragma mark - Query
- (MFDbList *)executeQuery:(NSString *)sql
{
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [innerDb inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MFDbRow *row = [[MFDbRow alloc] initWithDictionary:[rs resultDictionary]];
            [resultArray addObject:row];
            [row release];
        }
        [rs close];
    }];
    return (MFDbList *)resultArray;
}

- (MFDbList *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments
{
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [innerDb inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:arguments];
        while ([rs next]) {
            MFDbRow *row = [[MFDbRow alloc] initWithDictionary:[rs resultDictionary]];
            [resultArray addObject:row];
            [row release];
        }
        [rs close];
    }];
    return (MFDbList *)resultArray;
}

- (MFDbList *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments
{
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [innerDb inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withParameterDictionary:arguments];
        while ([rs next]) {
            MFDbRow *row = [[MFDbRow alloc] initWithDictionary:[rs resultDictionary]];
            [resultArray addObject:row];
            [row release];
        }
        [rs close];
    }];
    return (MFDbList *)resultArray;
}

#pragma mark - Update

- (BOOL)executeUpdate:(NSString *)sql
{
    __block BOOL result = NO;
    [innerDb inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (BOOL)executeUpdate:(NSString *)sql withArgumentsInArray:(NSArray *)arguments
{
    __block BOOL result = NO;
    [innerDb inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql withArgumentsInArray:arguments];
    }];
    return result;
}

- (BOOL)executeUpdate:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments
{
    __block BOOL result = NO;
    [innerDb inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql withParameterDictionary:arguments];
    }];
    return result;
}

@end

//
//  DHGoalDBInterface.m
//  GoalTasker328
//
//  Created by Derrick Ho on 5/25/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHGoalDBInterface.h"
#import "DHGoalDBObject.h"
#import <sqlite3.h>

static NSString *const kSqliteDatabaseName = @"goals.db";

@interface DHGoalDBInterface ()

@property (strong, atomic) NSString *docsDir;
@property (strong, atomic) NSArray *dirPaths;

@property (strong, atomic) NSString *databasePath;
@property (atomic) sqlite3 *goalDB;

@end

@implementation DHGoalDBInterface

+ (DHGoalDBInterface *)instance {
    static DHGoalDBInterface *instance = nil;
    @synchronized(self) {
        if(instance == nil) {
            instance = [DHGoalDBInterface new];
            [instance createDatabaseIfNeeded];
        }
    }
    return instance;
}

- (void)getDocumentsDirectory
{
    [self setDirPaths:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)];
    [self setDocsDir:self.dirPaths[0]];
}

- (void)buildPathToDatabaseFile
{
    [self setDatabasePath:[self.docsDir stringByAppendingPathComponent:kSqliteDatabaseName]];
    NSLog(@"DataBase path: %@", self.databasePath);
}

- (BOOL)createDatabaseIfNeeded
{
    BOOL success = YES;
    [self getDocumentsDirectory];
    [self buildPathToDatabaseFile];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if([fileMgr fileExistsAtPath:self.databasePath] == NO) {
        if (sqlite3_open(self.databasePath.UTF8String, &_goalDB) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt =
            " CREATE TABLE IF NOT EXISTS "
            " goals ( "
            "  id INTEGER PRIMARY KEY AUTOINCREMENT, " //the id will initially start at 1 then go up
            "  pid INTEGER, "
            "  description TEXT, "
            "  date_created TEXT, "
            "  date_modified TEXT, "
            "  accomplished INTEGER, "
            "  image TEXT "
            " ); ";
            
            int code;
            if ((code = sqlite3_exec(_goalDB, sql_stmt, NULL, NULL, &errMsg)) == SQLITE_OK) {
                NSLog(@"succesfully created table");
            } else {
                NSLog(@"Failed to create table: %d", code);
                success = NO;
            }
            sqlite3_close(_goalDB);
        } else {
            NSLog(@"Failed to open/create the Database");
            success = NO;
        }
    }
    
    return success;
}

- (void)updateTaskWithID:(NSNumber *)id taskDescription:(NSString *)taskDescription imageAsText:(NSString *)imageAsText complete:(void (^)(NSError *err, NSDictionary *obj))cb {
    NSString *query = [NSString stringWithFormat:
                       @"UPDATE goals SET "
                       " date_modified = DATETIME('NOW'), "
                       " description = '%@', "
                       " image = '%@' "
                       " WHERE id = %@ ", taskDescription, imageAsText, id];
    [self makeQuery:query completed:cb];
}

- (void)updateTaskWithID:(NSNumber *)id taskDescription:(NSString *)taskDescription image:(UIImage *)image complete:(void (^)(NSError *err, NSDictionary *obj))cb {
    NSData *imgAsData = UIImagePNGRepresentation(image);
    NSString *imgAsStr = [imgAsData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [self updateTaskWithID:id taskDescription:taskDescription imageAsText:imgAsStr complete:cb];
}

- (void)updateTaskWithID:(NSNumber *)id isAccomplished:(NSNumber *)accomplished complete:(void (^)(NSError *err, NSDictionary *obj))cb {
    [self makeQuery:[NSString stringWithFormat:
                     @"UPDATE goals SET "
                     " date_modified = DATETIME('NOW'), "
                     " accomplished = %@ "
                     " where id = %@ ", accomplished, id]
          completed:cb];
}

- (void)insertSomething:(NSDictionary *)obj complete:(void(^)(NSError *err, NSDictionary *obj))cb {
    NSString *query = [NSString stringWithFormat:
                       @"INSERT INTO goals ( "
                       " pid, "
                       " description, "
                       " date_created, "
                       " date_modified, "
                       " accomplished, "
                       " image "
                       " ) values (%@, '%@',DATETIME('%@'),DATETIME('%@'),%@, '%@');",
                       obj[@"pid"],
                       obj[@"description"],
                       obj[@"date_created"],
                       obj[@"date_modified"],
                       obj[@"accomplished"],
                       obj[@"image"]];
    [self makeQuery:query completed:cb];
}

- (void)get_everything:(void(^)(NSError *err, NSDictionary *obj))cb
{
    NSString *query =
    @"SELECT id, "
    "       pid, "
    "       description, "
    "       date_created, "
    "       date_modified, "
    "       accomplished, "
    "       image "
    " FROM goals "
    " ORDER BY date_created DESC; ";
    [self makeQuery:query completed:cb];
}

- (void)get_everything_from_parent:(int)pid complete:(void (^)(NSError *, NSDictionary *))cb {
    NSString *query = [NSString stringWithFormat:
                       @"SELECT id, "
                       "       pid, "
                       "       description, "
                       "       date_created, "
                       "       date_modified, "
                       "       accomplished, "
                       "       image "
                       " FROM goals "
                       " WHERE pid = %d "
                       " ORDER BY date_created DESC ",
                       pid];
    [self makeQuery:query completed:cb];
}

- (void)getRowUnderParent:(NSUInteger)pid atRow:(NSUInteger)rowIndex complete:(void (^)(NSError *, NSDictionary *))cb {
    NSString *query = [NSString stringWithFormat:
                       @"SELECT id, "
                       "        pid, "
                       "        description, "
                       "        date_created, "
                       "        date_modified, "
                       "        accomplished, "
                       "        image "
                       " FROM goals "
                       " WHERE pid = %ld "
                       " ORDER BY accomplished ASC, date_modified DESC "
                       " LIMIT 1 OFFSET %ld ", pid, rowIndex];
    [self makeQuery:query
          completed:cb];
}

- (void)getRowWithId:(NSUInteger)id complete:(void (^)(NSError *, NSDictionary *))cb {
    NSString *query = [NSString stringWithFormat:
                       @"SELECT * "
                       " FROM goals "
                       " WHERE id = %ld ", id];
    [self makeQuery:query completed:cb];
}

- (void)totalNumberOfRowsWithCallBack:(void (^)(NSError *, NSDictionary *))cb {
    NSString *query = [NSString stringWithFormat:
                       @"SELECT count(id) "
                       " from goals "];
    [self makeQuery:query completed:cb];
}

- (void)totalNumberOfRowsUnderParentId:(NSUInteger)pid withCallBack:(void (^)(NSError *, NSDictionary *))cb {
    NSString *query = [NSString stringWithFormat:
                       @"SELECT count(id) "
                       " from goals "
                       " WHERE pid = %ld ", pid];
    [self makeQuery:query completed:cb];
}

- (void)makeQuery:(NSString *)query completed:(void(^)(NSError *err, NSDictionary *obj))cb
{
    sqlite3_stmt *statement;
    int step;
    if (sqlite3_open(self.databasePath.UTF8String, &_goalDB) == SQLITE_OK) {
        if(sqlite3_prepare_v2(_goalDB, query.UTF8String, -1, &statement, NULL) == SQLITE_OK) {
            for (BOOL keepLooping = YES; keepLooping;) {
                step = sqlite3_step(statement);
                switch (step) {
                    case SQLITE_ROW:
                        [self makeDictFromStatement:statement];
                        break;
                    case SQLITE_DONE:
                        if (cb) {cb(nil, [self makeDictFromStatement:nil]);}
                        keepLooping = NO;
                        break;
                    default: //error state
                        if (cb ) {cb([self generateError], nil);}
                        keepLooping = NO;
                        break;
                }
            }
            sqlite3_finalize(statement);
        } else {
            NSLog(@"Could not prepare");
            if(cb) {cb([self generateError], nil);}
        }
        sqlite3_close(_goalDB);
    }
}

- (NSError *)generateError {
    NSError *err = [[NSError alloc] init];
    //NSError *err = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:nil]
    return err;
}

- (NSDictionary *)makeDictFromStatement:(sqlite3_stmt *)statement
{
    static NSMutableDictionary *dict = nil;
    if (statement == nil) {
        NSMutableDictionary *r_dict = dict;
        dict = nil;
        return r_dict;
    }
    if (dict == nil) {
        dict = [NSMutableDictionary new];
        [dict setObject:[NSMutableArray new] forKey:@"rows"];
    }
    int num_col = sqlite3_column_count(statement);
    NSMutableDictionary *inner_dict = [NSMutableDictionary new];
    for (int i = 0; i < num_col; ++i) {
        if ( sqlite3_column_type(statement, i) == SQLITE_TEXT) {
            NSString *obj = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
            NSString *key = [NSString stringWithUTF8String:(char *)sqlite3_column_name(statement, i)];
            [inner_dict setObject:obj forKey:key];
        } else if ( sqlite3_column_type(statement, i) == SQLITE_INTEGER) {
            NSString *obj = [NSString stringWithFormat:@"%d",sqlite3_column_int(statement, i)];
            NSString *key = [NSString stringWithUTF8String:(char *)sqlite3_column_name(statement, i)];
            [inner_dict setObject:obj forKey:key];
        }
    }
    [[dict objectForKey:@"rows"] addObject:inner_dict];
    return dict;
}

@end

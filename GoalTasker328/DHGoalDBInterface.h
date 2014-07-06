//
//  DHGoalDBInterface.h
//  GoalTasker328
//
//  Created by Derrick Ho on 5/25/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHGoalDBInterface : NSObject

+ (DHGoalDBInterface *)instance;
//TODO:this should be replaced with specifics in orer to prevent a wrong insertion of a diciontary
//- (void)insertSomething:(NSDictionary *)obj complete:(void(^)(NSError *err, NSDictionary *obj))cb DEPRECATED_ATTRIBUTE;

/**
 Generates a new entry into the database.
 @param pid The parent id that you want to add this under.
 @param desc the text that gets saved into the task
 @param imagePath a path to the image
 @param imgOrientation an integer value detailes the orientation of the image
 @param cb a call back function that lets you deal with err.  Obj is always null
 */
- (void)insertNewEntryUnderPID:(NSUInteger)pid description:(NSString *)desc imagePath:(NSString *)imagePath imageOrientation:(NSUInteger)imgOrientation complete:(void(^)(NSError *err, NSDictionary *obj)) cb;

/**
 Delete the specified row with id
 */
- (void)deleteRowThatHasId:(NSUInteger)id complete:(void(^)(NSError *err, NSDictionary *obj))cb ;

- (void)updateTaskWithID:(NSUInteger)id taskDescription:(NSString *)taskDescription imageAsText:(NSString *)imageAsText imageOrientation:(NSUInteger)imageOrientation complete:(void (^)(NSError *err, NSDictionary *obj))cb;
//- (void)updateTaskWithID:(NSNumber *)id taskDescription:(NSString *)taskDescription image:(UIImage *)image complete:(void (^)(NSError *err, NSDictionary *obj))cb;
- (void)updateTaskWithID:(NSUInteger)id isAccomplished:(BOOL)accomplished complete:(void (^)(NSError *err, NSDictionary *obj))cb;

/**
 Calls SELECT on the goal table.  Filtering it based on creation date in descending order
 Successful query will return a dictionary containing a key 'rows' for an array object.
 Each object in the array contains each column from the goal table.
 */
//- (void)get_everything:(void(^)(NSError *err, NSDictionary *obj))cb DEPRECATED_ATTRIBUTE;

/**
 Calls SELECT on the goal table.  Filtering it based on creation date in descending order AND pid
 Successful query will return a dictionary containing a key 'rows' for an array object.
 Each object in the array contains each column from the goal table.
 */
//- (void)get_everything_from_parent:(int)pid complete:(void(^)(NSError *err, NSDictionary *obj))cb DEPRECATED_ATTRIBUTE;

/**
 Gets the row under a specific parent id and at the specified row.
 */
- (void)getRowUnderParent:(NSUInteger)pid atRow:(NSUInteger)rowIndex complete:(void (^)(NSError *err, NSDictionary *obj))cb;

/**
 returns the row associated with the given id
 */
- (void)getRowWithId:(NSUInteger)id complete:(void (^)(NSError *err, NSDictionary *obj)) cb;

/**
 Will return the current total number of rows in the goals table
 */
- (void)totalNumberOfRowsWithCallBack:(void (^)(NSError *err, NSDictionary *obj))cb;

/**
 Will return the current total number of rows that live under the given parent n the goals table
 */
- (void)totalNumberOfRowsUnderParentId:(NSUInteger)pid withCallBack:(void (^)(NSError *err, NSDictionary *obj))cb;

@end

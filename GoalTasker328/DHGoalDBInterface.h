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
//this should be replaced with specifics in orer to prevent a wrong insertion of a diciontary

- (void)insertSomething:(NSDictionary *)obj complete:(void(^)(NSError *err, NSDictionary *obj))cb DEPRECATED_ATTRIBUTE;

- (void)updateTaskWithID:(NSNumber *)id taskDescription:(NSString *)taskDescription imageAsText:(NSString *)imageAsText complete:(void (^)(NSError *, NSDictionary *))cb;
- (void)updateTaskWithID:(NSNumber *)id taskDescription:(NSString *)taskDescription image:(UIImage *)image complete:(void (^)(NSError *, NSDictionary *))cb;
- (void)updateTaskWithID:(NSNumber *)id isAccomplished:(NSNumber *)accomplished complete:(void (^)(NSError *, NSDictionary *))cb;
- (void)get_everything:(void(^)(NSError *err, NSDictionary *obj))cb;

- (void)get_everything_from_parent:(int)pid complete:(void(^)(NSError *err, NSDictionary *obj))cb;

@end

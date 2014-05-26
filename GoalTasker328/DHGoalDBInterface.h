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

- (void)insertSomething:(NSDictionary *)obj complete:(void(^)(NSError *err, NSDictionary *obj))cb;
- (void)get_everything:(void(^)(NSError *err, NSDictionary *obj))cb;

- (void)get_everything_from_parent:(int)pid complete:(void(^)(NSError *err, NSDictionary *obj))cb;

@end

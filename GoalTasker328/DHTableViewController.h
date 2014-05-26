//
//  DHViewController.h
//  GoalTasker328
//
//  Created by Derrick Ho on 5/25/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, atomic) NSArray *array_of_goals;

@end

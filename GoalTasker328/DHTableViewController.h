//
//  DHViewController.h
//  GoalTasker328
//
//  Created by Derrick Ho on 5/25/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHTableViewCell.h"
#import "DHEditTaskViewController.h"

@interface DHTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, DHEditTaskViewDelegate, DHTableViewCellDelegate>

@property (strong, atomic) NSArray *array_of_goals;
@property int parentID;
@end

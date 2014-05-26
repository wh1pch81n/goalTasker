//
//  DHViewController.m
//  GoalTasker328
//
//  Created by Derrick Ho on 5/25/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHTableViewController.h"
#import "DHGoalDBInterface.h"

static NSString *const kReuseIdentifierGoalCell = @"myGoal";

@interface DHTableViewController ()

@end

@implementation DHTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[self navigationItem] setTitle:[@(self.parentID) stringValue]];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseIdentifierGoalCell];
    
    UIBarButtonItem *r_button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewTask:)];
    [self.navigationItem setRightBarButtonItem:r_button];

    [self reloadArrayFromDatabase];
}

- (void)reloadArrayFromDatabase {
    [[DHGoalDBInterface instance] get_everything_from_parent:self.parentID complete:^(NSError *err, NSDictionary *obj) {
        if (err) {
            NSLog(@"insert error here");
        } else {
            [self setArray_of_goals:obj[@"rows"]];
            [self.tableView reloadData];
        }
    }];
    
}

- (void)insertNewTask:(id)sender {
    [[DHGoalDBInterface instance] insertSomething:@{@"pid":@(self.parentID),
                                                    @"description":@"hello world",
                                                    @"date_created":@"NOW",
                                                    @"date_modified":@"NOW",
                                                    @"accomplished":@(NO)}
                                         complete:
     ^(NSError *err, NSDictionary *obj) {
         if (err) {
             NSLog(@"insertion error");
         } else {
             [self reloadArrayFromDatabase];
         }
     }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)generateRandomArray {
    NSMutableArray *mut = [NSMutableArray new];
    static int value = 0;
    for (int i = 0; i < 5; ++i) {
        [mut addObject:[NSString stringWithFormat:@"%d", value++]];
    }
    return mut;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array_of_goals.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myGoal"
                                                            forIndexPath:indexPath];
    NSDictionary *obj = self.array_of_goals[indexPath.row];
    
    //[cell.textLabel setText:obj[@"description"]];
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setMinimumScaleFactor:0.3];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    NSString *label = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@",
                       obj[@"id"],
                       obj[@"pid"],
                       obj[@"description"],
                       obj[@"date_created"],
                       obj[@"date_modified"],
                       obj[@"accomplished"]];
    [cell.textLabel setText:label];
    
    NSLog(@"%@", obj);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected row at %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DHTableViewController *newTBVC = [[DHTableViewController alloc] init];
    [newTBVC setParentID:[self.array_of_goals[indexPath.row][@"id"] integerValue]];
    //[newTBVC setArray_of_goals:[self generateRandomArray]];
    
    [self.navigationController pushViewController:newTBVC animated:YES];
}

@end

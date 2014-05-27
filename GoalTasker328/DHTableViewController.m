//
//  DHViewController.m
//  GoalTasker328
//
//  Created by Derrick Ho on 5/25/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHTableViewController.h"
#import "DHGoalDBInterface.h"
#import "DHTableViewCell.h"

static NSString *const kReuseIdentifierGoalCell = @"myGoal";
static NSString *const kCustomNibNameGoalCell = @"DHTableViewCell";

@interface DHTableViewController ()

@property (nonatomic, strong) DHTableViewCell *prototypeCell;
@property (nonatomic, strong) DHEditTaskViewController *editTaskViewController;

@end

@implementation DHTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
     [self reloadArrayFromDatabase];
    [[self navigationItem] setTitle:[@(self.parentID) stringValue]];
    
    [self registerCustomTableViewCell];
    
    UIBarButtonItem *r_button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewTask:)];
    [self.navigationItem setRightBarButtonItem:r_button];

   
}

- (void)registerCustomTableViewCell {
     UINib *dhCustomNib = [UINib nibWithNibName:kCustomNibNameGoalCell bundle:nil];
    [self.tableView registerNib:dhCustomNib forCellReuseIdentifier:kReuseIdentifierGoalCell];
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.prototypeCell) {
        self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:kReuseIdentifierGoalCell];
    }
    [self configureCell:self.prototypeCell forIndexPath:indexPath isForOffscreenUse:YES];
    
    [self.prototypeCell layoutIfNeeded];
    //CGSize size = self. prototypeCell.frame.size;
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height +1; //plus 1 for the cell separator
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   DHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierGoalCell forIndexPath:indexPath];
   [self configureCell:cell forIndexPath:indexPath isForOffscreenUse:NO];
        
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

- (void)configureCell:(DHTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath isForOffscreenUse:(BOOL)offscreenUse {
    if (cell == nil) {
        return;
    }
    NSDictionary *obj = self.array_of_goals[indexPath.row];
   // [cell setImageStored:]; //TODO:Figure out how to add image
    [cell setDelegate:self];
    [[cell detailsOfTask] setText:obj[@"description"]];
    [[cell toggleAccomplishment] setHighlighted:[obj[@"accomplished"] boolValue]];
    [[cell dateCreated] setText:obj[@"date_created"]];
    [[cell dateModified] setText:obj[@"date_modified"]];
}

#pragma mark - DHTableViewCellDelegate

- (void)tappedEditButton:(id)sender {
    DHEditTaskViewController *view = [[DHEditTaskViewController alloc] initWithNibName:@"DHEditTaskView" bundle:nil];
    [view setDelegate:self];
    [self setEditTaskViewController:view];
   // [view setBackgroundColor:[UIColor redColor]];
    //[self.navigationController.view addSubview:view];
    //[self.navigationController.view bringSubviewToFront:view];
    //[view setHidden:NO];
    [self presentViewController:view animated:YES completion:nil];
}

#pragma mark - DHEditTaskViewDelegate

- (void)tappedDoneButton:(id)sender {
    
}

- (void)tappedCloseButton:(id)sender {
    
}

- (void)tappedImageButton:(id)sender imageView:(UIImageView *)image {
    
}

@end

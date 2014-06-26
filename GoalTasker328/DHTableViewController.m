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

typedef enum : NSUInteger {
    DHEditTaskModeNewTask, //state that implies a new task
    DHEditTaskModeUpdateTask //state that implies updating a task
} DHEditTaskMode;

@interface DHTableViewController ()

@property (nonatomic, strong) DHTableViewCell *prototypeCell;
@property (nonatomic, strong) DHEditTaskViewController *editTaskViewController;

@property (assign) DHEditTaskMode editTaskViewMode;

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadArrayFromDatabase];
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
            [self setArray_of_goals:obj[@"rows"]];//TODO: is there a more efficent way?  
            [self.tableView reloadData];
        }
    }];
    
}

- (void)insertNewTask:(id)sender {
    [self presentEditViewControllerWithMode:DHEditTaskModeNewTask initializations:^(DHEditTaskViewController *editView) {
        [editView setDescription:@""];
    }];
}

- (void)presentEditViewControllerWithMode:(DHEditTaskMode)mode initializations:(void(^)(DHEditTaskViewController *editView))init{
    self.editTaskViewMode = mode;
    DHEditTaskViewController *view = [[DHEditTaskViewController alloc] initWithNibName:@"DHEditTaskView" bundle:nil];
    [view setDelegate:self];
    [self setEditTaskViewController:view];
    [self presentViewController:view animated:YES completion:nil];
    if (init) {
        init(view);
    }
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
    __block NSInteger count = 0;
    [[DHGoalDBInterface instance] totalNumberOfRowsUnderParentId:self.parentID withCallBack:^(NSError *err, NSDictionary *obj) {
        if (err) {
            NSLog(@"Unable to get total");
            return;
        }
        count = [[obj[@"rows"] lastObject][@"count(id)"] integerValue];
    }];
    
    return count;
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
    
    [cell setDelegate:self];
    
    [[DHGoalDBInterface instance] getRowUnderParent:self.parentID atRow:indexPath.row complete:^(NSError *err, NSDictionary *obj) {
        if (err) {
            NSLog(@"Could not get table information");
            return;
        }
        NSDictionary *row = obj[@"rows"][0];
        
        [cell setId:row[@"id"]];
        [cell setPid:row[@"pid"]];
        [cell setDescription:row[@"description"]];
        [cell setDate_created:row[@"date_created"]];
        [cell setDate_modified:row[@"date_modified"]];
        [cell setAccomplished:row[@"accomplished"]];
        [cell setImageAsText:row[@"image"]];
    }];
}

#pragma mark - DHTableViewCellDelegate

- (void)tableViewCell:(DHTableViewCell *)tvCell editButtonPressed:(UIButton *)sender {
    [self presentEditViewControllerWithMode:DHEditTaskModeUpdateTask initializations:^(DHEditTaskViewController *editView) {
        
        [editView setDescription:tvCell.description];
        [editView setId:tvCell.id];
        [editView setImageAsString:tvCell.imageAsText];
    }];
}

- (void)tableViewCell:(DHTableViewCell *)tvCell accomplishedPressed:(UISwitch *)sender {
    __weak typeof(self)wSelf = self;
    [[DHGoalDBInterface instance]
     updateTaskWithID:tvCell.id isAccomplished:@(sender.on) complete:^(NSError *err, NSDictionary *obj) {
         __strong typeof(wSelf)sSelf = wSelf;
         [sSelf reloadArrayFromDatabase];
     }];
}

#pragma mark - DHEditTaskViewDelegate

- (void)editTaskView:(DHEditTaskViewController *)editTaskView doneWithDescription:(NSString *)text image:(UIImage *)image {
    //Code that will save the stuff.
    __weak typeof(self)wSelf = self;
    if (self.editTaskViewMode == DHEditTaskModeNewTask) {
        [[DHGoalDBInterface instance]
         insertSomething:@{@"pid":@(self.parentID),
                           @"description":text,
                           @"date_created":@"NOW",
                           @"date_modified":@"NOW",
                           @"accomplished":@(NO),
                           @"image":@""}//Derrickfix images
         complete:^(NSError *err, NSDictionary *obj) {
             __strong typeof(wSelf)sSelf = wSelf;
             if (err) {
                 NSLog(@"insertion error");
             } else {
                 [sSelf reloadArrayFromDatabase];
             }
         }];
    } else if (self.editTaskViewMode == DHEditTaskModeUpdateTask) {
        //TODO: need to create query function that will allow me to update: image, text, and date_modified
        [[DHGoalDBInterface instance]
         updateTaskWithID:editTaskView.id
         taskDescription:text
         image:image
         complete:^(NSError *err, NSDictionary *obj) {
             __strong typeof(wSelf)sSelf = wSelf;
             if(err ) {
                 NSLog(@"updating error");
             } else {
                 [sSelf reloadArrayFromDatabase];
             }
         }];
    }
}

//TODO: functiont aht will handle when the accomplishment switch is toggleed

//TODO: handle the deletions

- (void)editTaskView:(DHEditTaskViewController *)editTaskView closeWithSender:(id)sender {
    
}

//- (void)tappedImageButton:(id)sender imageView:(UIImageView *)image {
//    
//}

@end

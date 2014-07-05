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
#import "UIImage+DHScaledImage.h"

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
    [[self navigationItem] setTitle:[@(self.parentID) stringValue]];
    
    [self registerCustomTableViewCell];
    
    UIBarButtonItem *r_button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewTask:)];
    [self.navigationItem setRightBarButtonItem:r_button];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)registerCustomTableViewCell {
     UINib *dhCustomNib = [UINib nibWithNibName:kCustomNibNameGoalCell bundle:nil];
    [self.tableView registerNib:dhCustomNib forCellReuseIdentifier:kReuseIdentifierGoalCell];
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
    
    //[self.prototypeCell layoutIfNeeded];
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

    [[DHGoalDBInterface instance] getRowUnderParent:self.parentID atRow:indexPath.row complete:^(NSError *err, NSDictionary *obj) {
        if (err) {
            NSLog(@"Unable to get row");
            return;
        }
        NSDictionary *row = obj[@"rows"][0];
        [newTBVC setParentID:[row[@"id"] integerValue]];
    }];
    [self.navigationController pushViewController:newTBVC animated:YES];
}

- (void)configureCell:(DHTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath isForOffscreenUse:(BOOL)offscreenUse {
    if (cell == nil) {
        return;
    }
    
    [cell setDelegate:self];
    
    __weak typeof(self)wSelf = self;
    [[DHGoalDBInterface instance] getRowUnderParent:self.parentID atRow:indexPath.row complete:^(NSError *err, NSDictionary *obj) {
        __strong typeof(wSelf)sSelf = wSelf;
        if (err) {
            NSLog(@"Could not get table information");
            return;
        }
        
        NSDictionary *row = obj[@"rows"][0];
        
        if (offscreenUse) { // You can do stuff asynchronously here and dont have to load the image
            [cell setDescription:row[@"description"]];
        } else { //since it now part of the view you should set the properties on the main queue, but read the files of the image asyncronously and only when it is done would you load it ot the main queue
            
            [cell setId:row[@"id"]];
            [cell setPid:row[@"pid"]];
            [cell setDescription:row[@"description"]];
            [cell setDate_created:row[@"date_created"] adjustForLocalTime:YES];
            [cell setDate_modified:row[@"date_modified"] adjustForLocalTime:YES];
            [cell setAccomplished:row[@"accomplished"]];
            [cell setImageAsText:row[@"image"]];
            [cell setImageOrientation:row[@"image_orientation"]];
            [cell.imageStored setImage:nil];
            __weak typeof(sSelf)wSelf = sSelf;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __strong typeof(wSelf)sSelf = wSelf;
                
                if ([row[@"image"] isEqualToString:@""]){return;}
                NSString *thumbPath = [row[@"image"] stringByAppendingPathExtension:@"thumbnail"];
                UIImage *thumbnail = [UIImage imageWithContentsOfFile:thumbPath];
                thumbnail = [UIImage imageWithCGImage:thumbnail.CGImage
                                                scale:1.0 orientation:[row[@"image_orientation"] integerValue]];
                __weak typeof(sSelf)wSelf = sSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(wSelf)sSelf = wSelf;
                    DHTableViewCell *cell = (id)[sSelf.tableView cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        [cell.imageStored setImage:thumbnail];
                    }
                });
            });
        }
    }];
}

#pragma mark - DHTableViewCellDelegate

- (void)tableViewCell:(DHTableViewCell *)tvCell editButtonPressed:(UIButton *)sender {
    [self presentEditViewControllerWithMode:DHEditTaskModeUpdateTask initializations:^(DHEditTaskViewController *editView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [editView setDescription:tvCell.description];
            [editView setId:tvCell.id];
            [editView setImagePath:tvCell.imageAsText];
            [editView setCell:tvCell];
            [editView setImageOrientation:tvCell.imageOrientation];
        });
    }];
}

- (void)tableViewCell:(DHTableViewCell *)tvCell accomplishedPressed:(UISwitch *)sender {
    __weak typeof(self)wSelf = self;
    [[DHGoalDBInterface instance]
     updateTaskWithID:tvCell.id isAccomplished:@(sender.on) complete:^(NSError *err, NSDictionary *obj) {
         __strong typeof(wSelf)sSelf = wSelf;
         [sSelf.tableView reloadData];
     }];
}

#pragma mark - DHEditTaskViewDelegate

- (void)editTaskView:(DHEditTaskViewController *)editTaskView doneWithDescription:(NSString *)text imagePath:(NSString *)imagePath imageOrientation:(NSNumber *)imageOrientation {
    
    if (imagePath) {
        //move imageAsStr from volitile directory to persistent documents directory
        NSString *oldPath = imagePath;
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        imagePath = [docDir stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
        
        NSError *err;
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:imagePath error:&err];
        if(err){
            NSLog(@"Failed to move image to new location:%@", [err localizedDescription]);
        }
        [[NSFileManager defaultManager]
         moveItemAtPath:[oldPath stringByAppendingPathExtension:@"thumbnail"]
         toPath:[imagePath stringByAppendingPathExtension:@"thumbnail"]
         error:&err];
        if(err){
            NSLog(@"Failed to move thumbnail to new location:%@", [err localizedDescription]);
        }
    }
    
    //convert text->data->datastr because a single quote from plain text might make the save fail
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    __weak typeof(self)wSelf = self;
    if (self.editTaskViewMode == DHEditTaskModeNewTask) {
               
        [[DHGoalDBInterface instance]
         insertSomething:@{@"pid":@(self.parentID),
                           @"description":dataStr,
                           @"date_created":@"NOW",
                           @"date_modified":@"NOW",
                           @"accomplished":@(NO),
                           @"image":imagePath?:@"",
                           @"image_orientation":imageOrientation?:@(0)
                           }
         complete:^(NSError *err, NSDictionary *obj) {
             __strong typeof(wSelf)sSelf = wSelf;
             if (err) {
                 NSLog(@"insertion error");
             } else {
                 [sSelf.tableView reloadData];
             }
         }];
    } else if (self.editTaskViewMode == DHEditTaskModeUpdateTask) {
        //find old image file path if any then move it to a volitile directory
        [[DHGoalDBInterface instance]
         getRowWithId:editTaskView.id.integerValue complete:^(NSError *err, NSDictionary *obj) {
             if (err){NSLog(@"Could not load row object"); return;}
             NSString *path = obj[@"rows"][0][@"image"];
             if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                 //move old image files to volitile space.
                 NSString *libCacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                 NSString *uniqueFileName = [[NSUUID UUID] UUIDString];
                 NSString *newPath = [libCacheDir stringByAppendingPathComponent:uniqueFileName];
                 NSError *err;
                 [[NSFileManager defaultManager] moveItemAtPath:path toPath:newPath error:&err];
                 if(err) {NSLog(@"Error: %@", [err localizedDescription]);}
             
                 NSString *pathThumb = [path stringByAppendingPathExtension:@"thumbnail"];
                 if ([[NSFileManager defaultManager] fileExistsAtPath:pathThumb]) {
                     //move old image thumb files to volitile space.
                     NSString *libCacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                     NSString *uniqueFileName = [[NSUUID UUID] UUIDString];
                     NSString *newPath = [libCacheDir stringByAppendingPathComponent:uniqueFileName];
                     NSError *err;
                     [[NSFileManager defaultManager] moveItemAtPath:pathThumb toPath:newPath error:&err];
                     if(err) {NSLog(@"Error: %@", [err localizedDescription]);}
                 }
             }
         }];
        
        [[DHGoalDBInterface instance]
         updateTaskWithID:editTaskView.id
         taskDescription:dataStr
         imageAsText:imagePath?:@""
         imageOrientation:imageOrientation?:@(0)
         complete:^(NSError *err, NSDictionary *obj) {
             __strong typeof(wSelf)sSelf = wSelf;
             if(err ) {
                 NSLog(@"updating error");
                 return;
             }
             [sSelf.tableView reloadData];
             
             //since the modified one will become the top one, just scroll all the way to the top
             NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
             [sSelf.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionTop];
             [sSelf.tableView deselectRowAtIndexPath:indexpath animated:YES];
         }];
    }
}

//TODO: handle the deletions frm sqlite database.  Also remember to delete picture from disk

- (void)editTaskView:(DHEditTaskViewController *)editTaskView closeWithSender:(id)sender {
    
}

//- (void)tappedImageButton:(id)sender imageView:(UIImageView *)image {
//    
//}


@end

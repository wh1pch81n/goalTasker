//
//  DHTableViewCell.h
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DHTableViewCell;
@protocol DHTableViewCellDelegate <NSObject>

@required
- (void)tableViewCell:(DHTableViewCell *)tvCell editButtonPressed:(UIButton *)sender;
- (void)tableViewCell:(DHTableViewCell *)tvCell accomplishedPressed:(UISwitch *)sender;

@end

@interface DHTableViewCell : UITableViewCell

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *pid;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *date_created;
@property (strong, nonatomic) NSString *date_modified;
@property (strong, nonatomic) NSNumber *accomplished;
@property (weak, nonatomic) IBOutlet UIImageView *imageStored;
@property (strong, nonatomic) NSString *imageAsText;

@property (weak) id<DHTableViewCellDelegate> delegate;

- (void)setDate_created:(NSString *)date_created adjustForLocalTime:(bool)isLocalTime;
- (void)setDate_modified:(NSString *)date_modified adjustForLocalTime:(bool)isLocalTime;

@end



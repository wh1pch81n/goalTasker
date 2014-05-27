//
//  DHTableViewCell.h
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DHTableViewDelegate <NSObject>

- (void)tappedAccomplished:(id)sender;
- (void)tappedDescription:(id)sender;

@end

@interface DHTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *accomplished; //if accomplish is enabled, it should be visible, other wise it will be grey.
@property (weak, nonatomic) IBOutlet UISwitch *toggleAccomplishment; //Tapping this should also toggle accomplishment

@property (weak, nonatomic) IBOutlet UILabel *dateCreated;
@property (weak, nonatomic) IBOutlet UILabel *dateModified;
@property (weak, nonatomic) IBOutlet UILabel *description;


@property (weak) id<DHTableViewDelegate> delegate;

@end


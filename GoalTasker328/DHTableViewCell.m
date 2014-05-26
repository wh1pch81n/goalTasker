//
//  DHTableViewCell.m
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHTableViewCell.h"

@implementation DHTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tappedDescriptionButton:(id)sender {
    if (self.delegate) {
        [self.delegate tappedDescription:sender];
    }
}
- (IBAction)tappedAccomplished:(id)sender {
    if (self.delegate) {
        [self.delegate tappedAccomplished:sender];
    }
}


@end

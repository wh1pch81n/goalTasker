//
//  DHEditTaskView.m
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHEditTaskViewController.h"

@implementation DHEditTaskViewController

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)tappedImage:(id)sender {
    NSLog(@"Just Tapped Image");
    if (self.delegate) {
        [self.delegate tappedImageButton:sender imageView:self.image];
    }
}
- (IBAction)tappedDoneButton:(id)sender {
    NSLog(@"Just Tapped Done");
    if (self.delegate) {
        [self.delegate tappedDoneButton:sender];
    }
}
- (IBAction)tappedCloseButton:(id)sender {
    NSLog(@"Just tapped close");
    if (self.delegate) {
        [self.delegate tappedCloseButton:sender];
    }
}

@end

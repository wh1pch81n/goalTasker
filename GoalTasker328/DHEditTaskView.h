//
//  DHEditTaskView.h
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DHEditTaskViewDelegate <NSObject>

- (void)tappedDoneButton:(id)sender;
- (void)tappedCloseButton:(id)sender;
- (void)tappedImageButton:(id)sender imageView:(UIImageView *)image;

@end

@interface DHEditTaskView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak) id<DHEditTaskViewDelegate> delegate;

@end

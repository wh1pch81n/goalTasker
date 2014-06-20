//
//  DHEditTaskView.h
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DHEditTaskViewController;
@protocol DHEditTaskViewDelegate <NSObject>

- (void)editTaskView:(DHEditTaskViewController *)editTaskView doneWithDescription:(NSString *)text image:(UIImage *)image;
- (void)editTaskView:(DHEditTaskViewController *)editTaskView closeWithSender:(id)sender;
//- (void)tappedImageButton:(id)sender imageView:(UIImageView *)image;

@end

@interface DHEditTaskViewController : UIViewController <UIImagePickerControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *imageAsString;
@property (strong, nonatomic) NSString *description;

@property (weak) id<DHEditTaskViewDelegate> delegate;

@end

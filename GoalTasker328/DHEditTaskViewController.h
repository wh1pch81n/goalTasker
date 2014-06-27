//
//  DHEditTaskView.h
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DHEditTaskViewController;
@class DHTableViewCell;
@protocol DHEditTaskViewDelegate <NSObject>

@required
- (void)editTaskView:(DHEditTaskViewController *)editTaskView doneWithDescription:(NSString *)text imageAsStr:(NSString *)imageAsStr;
- (void)editTaskView:(DHEditTaskViewController *)editTaskView closeWithSender:(id)sender;
//- (void)tappedImageButton:(id)sender imageView:(UIImageView *)image;

@end

@interface DHEditTaskViewController : UIViewController <UIImagePickerControllerDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *imageAsString;
@property (strong, nonatomic) NSString *description;
@property (weak, nonatomic) DHTableViewCell *cell;

@property (weak) id<DHEditTaskViewDelegate> delegate;

@end

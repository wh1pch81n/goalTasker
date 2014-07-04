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

/**
 called when the user pressed the done button in the edit taskview.
 @param editTaskView a reference to the edit task view
 @param text the text that was entered into the description
 @param imagePath the path to a file containing the chosen image.  Appending the path with "/thumbnail" will give you the path to the thumbnail version.  Both are saved in the library cache which is for temporary storage that will be cleared automatically by the opperating system.  If you wish to save this on disk and on the icloud you should move this file to the documents directory.
 @param imageOrientation an integer that specifies the orientation.
 */
- (void)editTaskView:(DHEditTaskViewController *)editTaskView doneWithDescription:(NSString *)text imagePath:(NSString *)imagePath imageOrientation:(NSNumber *)imageOrientation;

/**
 This is called when the cancel button is called.
 @param editTaskView a reference to the editTaskView 
 @param sender a reference to the sender
 */
- (void)editTaskView:(DHEditTaskViewController *)editTaskView closeWithSender:(id)sender;
//- (void)tappedImageButton:(id)sender imageView:(UIImageView *)image;

@end

@interface DHEditTaskViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSNumber *imageOrientation;
@property (strong, nonatomic) NSString *description;
@property (weak, nonatomic) DHTableViewCell *cell;

@property (weak) id<DHEditTaskViewDelegate> delegate;

@end

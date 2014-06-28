//
//  DHEditTaskView.m
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHEditTaskViewController.h"

@interface DHEditTaskViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;

@property (strong, nonatomic) NSString *libraryCacheImagePath;

@end

@implementation DHEditTaskViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(imageAsString)) options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(description)) options:NSKeyValueObservingOptionNew context:nil];
    
    [self.textView becomeFirstResponder];
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(imageAsString))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(description))];
    [self.textView resignFirstResponder];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(description))]) {
        [self.textView setText:self.description];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(imageAsString))]) {
        if (!self.imageAsString || [self.imageAsString isEqualToString:@""]) {
            return;
        }
        __weak typeof(self)wSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(wSelf)sSelf = wSelf;
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfFile:self.imageAsString]];
            __weak typeof(sSelf)wSelf = sSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(wSelf)sSelf = wSelf;
                sSelf.image.image = img;
            });
        });
    }
}

- (IBAction)tappedImage:(id)sender {
    NSLog(@"Just Tapped Image");
    [self.textView resignFirstResponder];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"This device has a camera.  Asking the user what they want to use.");
        UIActionSheet *photoSourceSheet = [[UIActionSheet alloc]
                                           initWithTitle:@"Select Photo"
                                           delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                           otherButtonTitles:@"Take new Photo", @"Choose Existing Photo", nil];
        
        //show the action sheet near the add image button.
        [photoSourceSheet showInView:self.view];
    } else { //no camera. Just use the library
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = NO;
        picker.delegate = self;
        
        [self presentViewController:picker
                           animated:YES completion:nil];
        
    }

}

- (IBAction)tappedDoneButton:(id)sender {
    NSLog(@"Just Tapped Done");
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate editTaskView:self doneWithDescription:self.textView.text imageAsStr:self.libraryCacheImagePath];
        }
    }];
}

- (IBAction)tappedCloseButton:(id)sender {
    NSLog(@"Just tapped close");
    __weak typeof(self)wSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        __strong typeof(wSelf)sSelf = wSelf;
        if (sSelf.delegate) {
            [sSelf.delegate editTaskView:sSelf closeWithSender:sender];
        }
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.buttonDone setHidden:YES];
    __weak typeof(self)wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(wSelf)sSelf = wSelf;
        __weak typeof(sSelf)wwSelf = sSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wwSelf)ssSelf = wwSelf;
            ssSelf.image.image = info[UIImagePickerControllerOriginalImage];
        });
    });
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(wSelf)sSelf = wSelf;
        
        //construct the path to the file in our Documents director.
        NSString *libraryCacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask, YES) lastObject];
        NSString *uniqueFileName = [[NSUUID UUID] UUIDString];
        NSString *imagePath = [libraryCacheDir stringByAppendingPathComponent:uniqueFileName];
        
        //get the image from the picker and write it to disk
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSData *imageAsData = UIImagePNGRepresentation(image);
        [imageAsData writeToFile:imagePath atomically:YES];
        
        //Save temporary path
        sSelf.libraryCacheImagePath = imagePath;
        dispatch_async(dispatch_get_main_queue(), ^{
            [sSelf.buttonDone setHidden:NO];
        });
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"Cancled Action Sheet");
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    [picker setAllowsEditing:NO];
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"user wants to take a new picture");
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
            
        default:
            NSLog(@"user want to get photo from library");
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

@end

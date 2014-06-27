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
        [self.image setImage:[UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:self.imageAsString options:NSDataBase64DecodingIgnoreUnknownCharacters]]];
    }
    
}

- (IBAction)tappedImage:(id)sender {
    NSLog(@"Just Tapped Image");
    [self.textView resignFirstResponder];
    //TODO:how will the timage stuff play out?
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
//    if (self.delegate) {
//        [self.delegate tappedImageButton:sender imageView:self.image];
//    }
}

- (IBAction)tappedDoneButton:(id)sender { //TODO: Send delegate the  new data via dictionary (
    NSLog(@"Just Tapped Done");
    __weak typeof(self)wSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        __strong typeof(wSelf)sSelf = wSelf;
        if (sSelf.delegate) {
           // [sSelf.delegate editTaskView:sSelf doneWithDescription:self.textView.text image:self.image.image];
            [sSelf setDescription:self.textView.text];
            [sSelf.delegate editTaskView:sSelf doneWithDescription:self.description imageAsStr:self.imageAsString];
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
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *imageAsData = UIImagePNGRepresentation(image);
    NSString *imageAsStr = [imageAsData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    self.imageAsString = imageAsStr;
    
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

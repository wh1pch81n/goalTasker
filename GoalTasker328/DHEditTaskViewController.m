//
//  DHEditTaskView.m
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHEditTaskViewController.h"
#import "UIImage+DHScaledImage.h"
#import "DHGlobalConstants.h"

@interface DHEditTaskViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;

@property (strong, nonatomic) NSString *libraryCacheImagePath;
@property (strong, nonatomic) NSNumber *libraryCacheImageOrientation;

@end

@implementation DHEditTaskViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(imagePath)) options:NSKeyValueObservingOptionNew context:nil];
    //[self addObserver:self forKeyPath:NSStringFromSelector(@selector(imageOrientation)) options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(description)) options:NSKeyValueObservingOptionNew context:nil];
    
    [self.textView becomeFirstResponder];
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(imagePath))];
    //[self removeObserver:self forKeyPath:NSStringFromSelector(@selector(imageOrientation))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(description))];
    [self.textView resignFirstResponder];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(description))]) {
        [self.textView setText:self.description];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(imagePath))]) {
        if (!self.imagePath || [self.imagePath isEqualToString:@""]) {return;}
        
        __weak typeof(self)wSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(wSelf)sSelf = wSelf;
            NSString *thumb = [self.imagePath stringByAppendingPathExtension:@"thumbnail"];
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfFile:thumb]];
            img = [UIImage imageWithCGImage:img.CGImage scale:1 orientation:self.imageOrientation.integerValue];
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
            [self.delegate editTaskView:self doneWithDescription:self.textView.text
                              imagePath:self.libraryCacheImagePath?:self.imagePath
                       imageOrientation:self.libraryCacheImageOrientation?:self.imageOrientation];
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __strong typeof(wSelf)sSelf = wSelf;
        
        //construct the path to the file in our Documents director.
        NSString *libraryCacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask, YES) lastObject];
        NSString *uniqueFileName = [[NSUUID UUID] UUIDString];
        NSString *imagePath = [libraryCacheDir stringByAppendingPathComponent:uniqueFileName];
        //Save temporary path
        sSelf.libraryCacheImagePath = imagePath;
        
        //get the image from the picker and write it to disk
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImage *imageThumb = [image imageScaledToFitInSize:kThumbImageSize];
        UIImage *imageFull = [image imageScaledToFitInSize:kFullImageSize];
        
        sSelf.libraryCacheImageOrientation = @(image.imageOrientation);//saving the image orientation
        
        __weak typeof(sSelf)wSelf = sSelf;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            //saving full image to disk
            NSData *imageAsData = UIImagePNGRepresentation(imageFull);
            [imageAsData writeToFile:imagePath atomically:YES];
            NSLog(@"done saving full image\n%@", imagePath);
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ //TODO: this might be slightly dangerous.  IT might be safer to move this code into the main thread.
            
            //saving thumbnail of image to disk.
            NSData *imageThumbAsData = UIImagePNGRepresentation(imageThumb);
            
            NSString *imageThumbPath = [imagePath stringByAppendingPathExtension:@"thumbnail"];
            [imageThumbAsData writeToFile:imageThumbPath atomically:YES];
            NSLog(@"done saving Thumbnail image\n%@", imageThumbPath);
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wSelf)sSelf = wSelf;
            [sSelf.buttonDone setHidden:NO];
            //TODO: Consider presenting a "loading" view on top rather than just hiding the button.  then finally dismiss this.
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(wSelf)sSelf = wSelf;
        __weak typeof(sSelf)wwSelf = sSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wwSelf)ssSelf = wwSelf;
            ssSelf.image.image = info[UIImagePickerControllerOriginalImage];
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

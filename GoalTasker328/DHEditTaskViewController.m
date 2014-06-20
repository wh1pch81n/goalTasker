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
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(imageAsString))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(description))];
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
    //TODO:how will the timage stuff play out?
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
            [sSelf.delegate editTaskView:sSelf doneWithDescription:self.textView.text image:self.image.image];
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



@end

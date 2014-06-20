//
//  DHTableViewCell.m
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHTableViewCell.h"

@interface DHTableViewCell ()

//@property (weak, nonatomic) IBOutlet UILabel *accomplished; //if accomplish is enabled, it should be visible, other wise it will be grey.
@property (weak, nonatomic) IBOutlet UISwitch *toggleAccomplishment; //Tapping this should also toggle accomplishment
@property (weak, nonatomic) IBOutlet UIImageView *imageStored;
@property (weak, nonatomic) IBOutlet UILabel *detailsOfTask;
@property (weak, nonatomic) IBOutlet UILabel *dateCreated;
@property (weak, nonatomic) IBOutlet UILabel *dateModified;
@end

@implementation DHTableViewCell

- (void)awakeFromNib
{
    // Initialization code
//    self.id = @(0);
//    self.pid = @(0);
//    self.description = @"";
//    self.date_created = @"";
//    self.date_modified = @"";
//    self.accomplished = @(0);
//    self.imageAsText = @"";
    
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(description))
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(date_created))
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(date_modified))
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(accomplished))
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(imageAsText))
              options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(description))]) {
        [[self detailsOfTask] setText:self.description];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(date_created))]) {
        [[self dateCreated] setText:self.date_created];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(date_modified))]) {
        [[self dateModified] setText:self.date_modified];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(accomplished))]) {
        [[self toggleAccomplishment] setOn:[self.accomplished boolValue] animated:YES];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(imageAsText))]) {
        [self setNoteImage:self.imageAsText];
    } else {
        NSLog(@"Unknown keypath triggered KVO method");
    }
}

- (void)setNoteImage:(NSString *)imageAsText {
    if (!self.imageAsText || [self.imageAsText isEqualToString:@""]) {
        return;
    }
    NSString *imgAsStr = self.imageAsText;
    NSData *imgAsData = [[NSData alloc] initWithBase64EncodedString:imgAsStr                                                    options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *img = [UIImage imageWithData:imgAsData];
    [[self imageStored] setImage:img];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (IBAction)tappedDescriptionButton:(id)sender {
//    if (self.delegate) {
//        [self.delegate tappedDescription:sender];
//    }
//}
//- (IBAction)tappedAccomplished:(id)sender {
//    if (self.delegate) {
//        [self.delegate tappedAccomplished:sender];
//    }
//}

- (IBAction)tappedEditButton:(id)sender {
    NSLog(@"tapped edit button");
    if (self.delegate) {
        [self.delegate tappedEditButton:sender];
    }
}

@end

//
//  DHTableViewCell.m
//  GoalTasker328
//
//  Created by Derrick Ho on 5/26/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHTableViewCell.h"

@interface DHTableViewCell ()

//@property (weak, nonatomic) IBOutlet UILabel *accomplished; //TODO: if accomplish is enabled, it should be visible, other wise it will be grey.
@property (weak, nonatomic) IBOutlet UISwitch *toggleAccomplishment; //Tapping this should also toggle accomplishment

@property (weak, nonatomic) IBOutlet UILabel *detailsOfTask;
@property (weak, nonatomic) IBOutlet UILabel *dateCreated;
@property (weak, nonatomic) IBOutlet UILabel *dateModified;

@end

@implementation DHTableViewCell

- (void)awakeFromNib
{
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
}

- (void)dealloc {
    
    [self removeObserver:self
           forKeyPath:NSStringFromSelector(@selector(description))];
    [self removeObserver:self
           forKeyPath:NSStringFromSelector(@selector(date_created))];
    [self removeObserver:self
           forKeyPath:NSStringFromSelector(@selector(date_modified))];
    [self removeObserver:self
           forKeyPath:NSStringFromSelector(@selector(accomplished))];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(description))]) {
        [[self detailsOfTask] setText:self.description];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(date_created))]) {
        [[self dateCreated] setText:self.date_created];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(date_modified))]) {
        [[self dateModified] setText:self.date_modified];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(accomplished))]) {
        [[self toggleAccomplishment] setOn:[self.accomplished boolValue] animated:NO];
    } else {
        NSLog(@"Unknown keypath triggered KVO method");
    }
}

- (void)setNoteImage:(NSString *)imageAsText {
    NSString *imgAsStr = self.imageAsText;
   
    if (imgAsStr) {
        __block NSData *imgAsData;
        __block UIImage *img;
        __weak typeof(self)wSelf = self;
        //TODO: Determine if this should actually be done asynchronously or not
       // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(wSelf)sSelf = wSelf;
            
            imgAsData = [NSData dataWithContentsOfFile:imgAsStr];
            img = [UIImage imageWithData:imgAsData];
            __weak typeof(sSelf)wwSelf = sSelf;
         //   dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(wwSelf)ssSelf = wwSelf;
                [[ssSelf imageStored] setImage:img];
           // });
        //});
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tappedEditButton:(id)sender {
    NSLog(@"tapped edit button");
    if (self.delegate) {
        [self.delegate tableViewCell:self editButtonPressed:sender];
    }
}

- (IBAction)tappedAccomplishedSwitch:(id)sender {
    NSLog(@"tapped Accomplished switch");
    if (self.delegate) {
        [self.delegate tableViewCell:self accomplishedPressed:sender];
    }
}


- (void)setDate_created:(NSString *)date_created adjustForLocalTime:(bool)isLocalTime {
    __weak typeof(self)wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(wSelf)sSelf = wSelf;
        NSString *date = [sSelf dateUTCStringToSystemTimeZone:date_created];
        __weak typeof(sSelf)wSelf = sSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wSelf)sSelf = wSelf;
            sSelf.date_created = date;
        });
    });
}

- (void)setDate_modified:(NSString *)date_modified adjustForLocalTime:(bool)isLocalTime {
    __weak typeof(self)wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(wSelf)sSelf = wSelf;
        NSString *date = [sSelf dateUTCStringToSystemTimeZone:date_modified];
        __weak typeof(sSelf)wSelf = sSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wSelf)sSelf = wSelf;
            sSelf.date_modified = date;
        });
    });
}

- (NSString *)dateUTCStringToSystemTimeZone:(NSString *)utcStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //create dateformattter
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]]; //set it to UTC
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //give it a dateformat
    NSDate *utcDate = [dateFormatter dateFromString:utcStr]; //give it a string that conforms to that format.
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *dateStrAdjForSystemTimeZone = [dateFormatter stringFromDate:utcDate];
    
    return dateStrAdjForSystemTimeZone;
}

- (void)setDescription:(NSString *)description {
    if (!description) {
        return;
    }

    NSData *dataStr = [[NSData alloc] initWithBase64EncodedString:description options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *originalStr = [[NSString alloc] initWithData:dataStr encoding:NSUTF8StringEncoding];
    _description = originalStr;
}

@end

//
//  UIImage+DHScaledImage.m
//  GoalTasker328
//
//  Created by Derrick Ho on 6/28/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "UIImage+DHScaledImage.h"

@implementation UIImage (DHScaledImage)

- (UIImage *)imageScaledToFitInSize:(CGSize)size {
    CGFloat scale;
    if (self.size.height > self.size.width) { //scale until height is equal to size.height
        scale = size.height / self.size.height;
    } else { //scale until height is equal to size.width
        scale = size.width / self.size.width;
    }

    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, self.size.width * scale, self.size.height * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end

/**
 UIImage *originalImage = ...;
 CGSize destinationSize = ...;
 UIGraphicsBeginImageContext(destinationSize);
 [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
 UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
*/
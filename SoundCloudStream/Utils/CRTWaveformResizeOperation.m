//
//  CRTWaveformResizeOperation.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 21.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTWaveformResizeOperation.h"

@interface CRTWaveformResizeOperation ()

@property (nonatomic, strong, readonly) UIImage *originalImage;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat scale;

@property (nonatomic, strong) UIImage *resizedImage;

@end

@implementation CRTWaveformResizeOperation

- (instancetype)initWithImage:(UIImage *)originalImage width:(CGFloat)width scale:(CGFloat)scale
{
    NSCParameterAssert(originalImage != nil);
    NSCParameterAssert(width > 0);
    NSCParameterAssert(scale > 0);

    self = [super init];

    if (self != nil) {
        _originalImage = originalImage;
        _width = width;
        _scale = scale;

        _result = [[RACObserve(self, resizedImage) ignore:nil] deliverOn:[RACScheduler currentScheduler]];
    }

    return self;
}

- (void)main
{
    UIImage *bigImage = self.originalImage;
    CGFloat scaleFactor = self.width / bigImage.size.width;

    size_t bigImageWidth = CGImageGetWidth(bigImage.CGImage);
    size_t bigImageHeight = CGImageGetHeight(bigImage.CGImage);
    CGRect croppedImageRect = CGRectMake(0, bigImageHeight / 2, bigImageWidth, bigImageHeight / 2);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(bigImage.CGImage,
            croppedImageRect);

    CGSize newSize = CGSizeMake(self.width, ceil(scaleFactor * bigImage.size.height));

    CGRect finalImageRect = (CGRect) {.origin = CGPointZero, .size = newSize};

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), finalImageRect, croppedImageRef);
    CGImageRelease(croppedImageRef);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.resizedImage = scaledImage;
}


@end

//
//  CRTWaveformResizeOperation.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 21.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//



/**
 This operation will crop bottom half of image and resize image proportionally to given width.
 Image will have provided scale (you want to use 2.0 on retina devices)
 */
@interface CRTWaveformResizeOperation : NSOperation

/**
 @param originalImage original waveform image
 @param width desired waveform width
 @param scale desired image scale, have noting to do with resizing!
 @see -[UIImage imageWithData:scale:]
 @see -[UIScreen scale]
 */
- (instancetype)initWithImage:(UIImage *)originalImage width:(CGFloat)width scale:(CGFloat)scale;

/// RACSignal[UIImage] This signal that will send image processing result on the scheduler where initializer was called
@property (nonatomic, strong, readonly) RACSignal *result;

@end

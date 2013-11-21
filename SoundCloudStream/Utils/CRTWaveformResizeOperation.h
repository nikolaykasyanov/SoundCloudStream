//
//  CRTWaveformResizeOperation.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 21.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//



@interface CRTWaveformResizeOperation : NSOperation

- (instancetype)initWithImage:(UIImage *)originalImage width:(CGFloat)width scale:(CGFloat)scale;

@property (nonatomic, strong, readonly) RACSignal *result;

@end

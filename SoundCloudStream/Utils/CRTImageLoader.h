//
//  CRTImageLoader.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 18.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFHTTPSessionManager.h>


@interface CRTImageLoader : AFHTTPSessionManager

/// Initializes image loader with maximum waveform width in points (320 would be okay for iPhone for example)
- (instancetype)initWithURLSessionConfiguration:(NSURLSessionConfiguration *)configuration
                               maxWaveformWidth:(CGFloat)maxWaveformWidth;

/**
 Returns signal that will download, crop & resize waveform image when subscribed.
 Signal is multicasted. If signal downloading same url is still active, it will be used instead of creating new one.

 @param url url of waveform

 @return RACSignal[UIImage] signal that will send a processed waveform or error
 */
- (RACSignal *)waveformFromURL:(NSURL *)url;

@end

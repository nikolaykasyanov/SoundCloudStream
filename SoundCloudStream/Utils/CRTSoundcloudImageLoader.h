//
//  CRTSoundcloudImageLoader.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 18.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFHTTPSessionManager.h>


@interface CRTSoundcloudImageLoader : AFHTTPSessionManager

- (instancetype)initWithURLSessionConfiguration:(NSURLSessionConfiguration *)configuration
                               maxWaveformWidth:(CGFloat)maxWaveformWidth;

- (RACSignal *)waveformFromURL:(NSURL *)url;

@end

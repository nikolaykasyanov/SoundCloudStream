//
//  CRTImageLoader.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 18.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTImageLoader.h"
#import "CRTWaveformResizeOperation.h"


@interface CRTImageLoader ()

@property (nonatomic, strong, readonly) RACScheduler *lockScheduler;

/**
 * NSMapTable[NSURL, weak RACSignal[UIImage]]
 * Maps URLs to corresponding running signal.
 *
 * Should be accessed **only** on `lockScheduler`.
 */
@property (nonatomic, strong, readonly) NSMapTable *activeSignals;

@property (nonatomic, readonly) CGFloat maxWaveformWidth;

@property (nonatomic, strong, readonly) NSOperationQueue *resizeQueue;

@end


@implementation CRTImageLoader

- (instancetype)initWithURLSessionConfiguration:(NSURLSessionConfiguration *)configuration
                               maxWaveformWidth:(CGFloat)maxWaveformWidth
{
    NSCParameterAssert(maxWaveformWidth > 0.0);

    self = [super initWithBaseURL:nil sessionConfiguration:configuration];

    if (self != nil) {
        _lockScheduler = [RACScheduler scheduler];
        _activeSignals = [NSMapTable strongToWeakObjectsMapTable];
        _maxWaveformWidth = maxWaveformWidth;
        _resizeQueue = [[NSOperationQueue alloc] init];
        _resizeQueue.maxConcurrentOperationCount = 2;
        _resizeQueue.name = [NSString stringWithFormat:@"%@@%p operation queue", NSStringFromClass(self.class), (__bridge void *)self];

        self.responseSerializer = [[AFImageResponseSerializer alloc] init];
    }

    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    return [self initWithURLSessionConfiguration:configuration maxWaveformWidth:320];
}

- (RACSignal *)waveformFromURL:(NSURL *)url
{
    return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        RACSignal *imageSignal = [self.activeSignals objectForKey:url];
        if (imageSignal == nil) {
            imageSignal = [[[[self rac_GET:url.absoluteString parameters:nil]
                    deliverOn:[RACScheduler scheduler]]
                    flattenMap:^RACStream *(UIImage *originalImage) {

                        CRTWaveformResizeOperation *resizeOperation =
                                [[CRTWaveformResizeOperation alloc] initWithImage:originalImage
                                                                            width:self.maxWaveformWidth
                                                                            scale:[UIScreen mainScreen].scale];

                        [self.resizeQueue addOperation:resizeOperation];

                        return resizeOperation.result;
                    }] replayLazily];
            [self.activeSignals setObject:imageSignal forKey:url];
        }

        return [imageSignal subscribe:subscriber];
    }] subscribeOn:self.lockScheduler]
         deliverOn:[RACScheduler currentScheduler]];
}

#pragma mark - Private methods

- (RACSignal *)rac_GET:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self GET:URLString
                                    parameters:parameters
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           [subscriber sendNext:responseObject];
                                           [subscriber sendCompleted];
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           [subscriber sendError:error];
                                       }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}


@end

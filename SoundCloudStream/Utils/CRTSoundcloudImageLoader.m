//
//  CRTSoundcloudImageLoader.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 18.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudImageLoader.h"


@interface CRTSoundcloudImageLoader ()

@property (nonatomic, strong, readonly) RACScheduler *lockScheduler;

/**
 * NSMapTable[NSURL, weak RACSignal[UIImage]]
 * Maps URLs to corresponding running signal.
 *
 * Should be accessed **only** on `lockScheduler`.
 */
@property (nonatomic, strong, readonly) NSMapTable *activeSignals;

@end


@implementation CRTSoundcloudImageLoader

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:nil sessionConfiguration:configuration];

    if (self != nil) {
        _lockScheduler = [RACScheduler scheduler];
        _activeSignals = [NSMapTable strongToWeakObjectsMapTable];

        AFImageResponseSerializer *responseSerializer = [[AFImageResponseSerializer alloc] init];
        self.responseSerializer = responseSerializer;
    }

    return self;
}

- (RACSignal *)imageFromURL:(NSURL *)url
{
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        RACSignal *imageSignal = [self.activeSignals objectForKey:url];
        if (imageSignal == nil) {
            imageSignal = [[self rac_GET:url.absoluteString parameters:nil] finally:^{
                [self.activeSignals removeObjectForKey:url];
            }];
            [self.activeSignals setObject:imageSignal forKey:url];
        }

        return [imageSignal subscribe:subscriber];
    }] subscribeOn:self.lockScheduler]
         deliverOn:[RACScheduler currentScheduler]]
            replayLazily];
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

//
//  CRTSoundcloudClient.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudClient.h"

#import "NSURL+CRTURLComparison.h"


@implementation CRTSoundcloudClient

- (RACSignal *)affiliatedTracksWithLimit:(NSUInteger)limit
{
    if (limit == 0) {
        return [RACSignal empty];
    }

    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        NSDictionary *parameters = @{@"limit" : @(limit)};

        NSURLSessionDataTask *task = [self GET:@"/me/activities/tracks/affiliated.json"
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
    }] replayLazily];
}

- (RACSignal *)collectionFromURL:(NSURL *)cursorURL itemsOfClass:(Class)itemClass
{
    NSCParameterAssert(cursorURL != nil && [self.baseURL crt_areSchemeAndHostMatchWithURL:cursorURL]);
    NSCParameterAssert(itemClass != Nil);

    return [RACSignal empty];
}


@end

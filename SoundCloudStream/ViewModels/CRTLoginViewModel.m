//
//  CRTLoginViewModel.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTLoginViewModel.h"

#import <GROAuth2SessionManager/GROAuth2SessionManager.h>


@interface CRTLoginViewModel ()

@property (nonatomic, copy) NSString *authToken;

@end


@implementation CRTLoginViewModel

- (instancetype)init
{
    self = [super init];

    if (self != nil) {
        NSURL *endpointURL = [NSURL URLWithString:CRTSoundcloudEndpointURLString];

        GROAuth2SessionManager *client = [GROAuth2SessionManager managerWithBaseURL:endpointURL
                                                                           clientID:CRTSoundcloudClientID
                                                                             secret:CRTSoundcloudSecret];

        _startLogin = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id _) {

            AFHTTPRequestSerializer *serializer = [[AFHTTPRequestSerializer alloc] init];

            NSURLRequest *request = [serializer requestWithMethod:@"GET"
                                                        URLString:CRTSoundcloudConnectURLString
                                                       parameters:@{
                                                               @"redirect_uri" : CRTSoundcloudBackURLString,
                                                               @"client_id" : CRTSoundcloudClientID,
                                                               @"consumer_Key" : CRTSoundcloudSecret,
                                                               @"response_type" : @"code",
                                                       }];

            NSURL *url = request.URL;

            [[UIApplication sharedApplication] openURL:url];

            return [RACSignal empty];
        }];
    }

    return self;
}

@end

//
//  CRTLoginViewModel.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTLoginViewModel.h"

#import <GROAuth2SessionManager/GROAuth2SessionManager.h>


static NSDictionary *ParametersFromQueryString(NSString *queryString)
{
    if (queryString.length == 0) {
        return @{};
    }

    NSArray *rawParams = [queryString componentsSeparatedByString:@"&"];

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:rawParams.count];

    for (NSString *rawParam in rawParams) {
        NSArray *keyAndValue = [rawParam componentsSeparatedByString:@"="];

        NSString *key = keyAndValue[0];

        id value;
        if (keyAndValue.count >= 2) {
            value = keyAndValue[1];
        }
        else {
            value = [NSNull null];
        }

        parameters[key] = value;
    }

    return [parameters copy];
}


@interface CRTLoginViewModel ()

@property (nonatomic, strong) AFOAuthCredential *OAuthCredential;

@property (nonatomic, strong, readonly) RACCommand *obtainToken;

@end


@implementation CRTLoginViewModel

@dynamic loading;

- (instancetype)initWithClient:(GROAuth2SessionManager *)client
             credentialStorage:(id <CRTCredentialStorage>)credentialStorage
{
    NSCParameterAssert(client != nil);
    NSCParameterAssert(credentialStorage != nil);

    self = [super init];

    if (self != nil) {

        @weakify(self);
        _obtainToken = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *code) {
            @strongify(self);
            return [[self authenticateUsingClient:client code:code] doNext:^(AFOAuthCredential *credential) {
                [credentialStorage setCredential:credential forKey:CRTSoundcloudCredentialsKey];
            }];
        }];

        _errors = _obtainToken.errors;

        _startLogin = [[RACCommand alloc] initWithEnabled:[_obtainToken.executing not]
                                              signalBlock:^RACSignal *(id _) {

                                                  AFHTTPRequestSerializer *serializer = [[AFHTTPRequestSerializer alloc] init];

                                                  NSURLRequest *request = [serializer requestWithMethod:@"GET"
                                                                                              URLString:CRTSoundcloudConnectURLString
                                                                                             parameters:@{
                                                                                                     @"redirect_uri" : CRTSoundcloudBackURLString,
                                                                                                     @"client_id" : CRTSoundcloudClientID,
                                                                                                     @"consumer_Key" : CRTSoundcloudSecret,
                                                                                                     @"response_type" : @"code",
                                                                                                     @"scope" : @"non-expiring",
                                                                                             }];

                                                  NSURL *url = request.URL;

                                                  [[UIApplication sharedApplication] openURL:url];

                                                  return [RACSignal empty];
                                              }];

        RACSignal *hasCredential = [RACObserve(self, OAuthCredential) map:^id(id value) {
            return @(value != nil);
        }];

        RAC(self, hasCredential) = hasCredential;

        _logout = [[RACCommand alloc] initWithEnabled:hasCredential
                                          signalBlock:^RACSignal *(id input) {
                                              return [[RACSignal empty] initially:^{
                                                  [credentialStorage deleteCredentialForKey:CRTSoundcloudCredentialsKey];
                                              }];
                                          }];

        RACSignal *notification = [[NSNotificationCenter defaultCenter] rac_addObserverForName:CRTOpenURLNotification
                                                                                        object:nil];

        RACSignal *authCode = [[[notification map:^NSString *(NSNotification *note) {
            return note.userInfo[CRTOpenURLNotificationURLKey];
        }] map:^NSString *(NSURL *redirectURL) {
            NSDictionary *parameters = ParametersFromQueryString(redirectURL.query);
            return parameters[@"code"];
        }] filter:^BOOL(NSString *code) {
            return code != nil;
        }];

        [_obtainToken rac_liftSelector:@selector(execute:) withSignals:authCode, nil];

        [client rac_liftSelector:@selector(setAuthorizationHeaderWithCredential:)
                     withSignals:RACObserve(self, OAuthCredential), nil];

        RAC(self, OAuthCredential) = [[RACSignal merge:@[
                [_obtainToken.executionSignals switchToLatest],
                [_logout.executionSignals mapReplace:nil],
        ]] startWith:[credentialStorage credentialForKey:CRTSoundcloudCredentialsKey]];
    }

    return self;
}

- (RACSignal *)authenticateUsingClient:(GROAuth2SessionManager *)client code:(NSString *)code
{
    NSCParameterAssert(client != nil);
    NSCParameterAssert(code != nil);

    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        [client authenticateUsingOAuthWithPath:@"/oauth2/token"
                                          code:code
                                   redirectURI:CRTSoundcloudBackURLString
                                       success:^(AFOAuthCredential *credential) {
                                           [subscriber sendNext:credential];
                                           [subscriber sendCompleted];
                                       }
                                       failure:^(NSError *error) {
                                           [subscriber sendError:error];
                                       }];

        return nil;
    }] replayLazily];
}

- (RACSignal *)loading
{
    return self.obtainToken.executing;
}

@end

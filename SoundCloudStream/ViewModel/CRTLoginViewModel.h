//
//  CRTLoginViewModel.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;
@class GROAuth2SessionManager;


@interface CRTLoginViewModel : NSObject

- (instancetype)init __attribute__((unavailable("Use -initWithClient: instead")));

- (instancetype)initWithClient:(GROAuth2SessionManager *)client;


@property (nonatomic, strong, readonly) RACCommand *startLogin;
@property (nonatomic, copy, readonly) NSString *authToken;

@end

//
//  CRTLoginViewModel.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFOAuthCredential;

@protocol CRTCredentialStorage <NSObject>

- (void)setCredential:(AFOAuthCredential *)credential forKey:(NSString *)key;
- (AFOAuthCredential *)credentialForKey:(NSString *)key;
- (void)deleteCredentialForKey:(NSString *)key;

@end


@class GROAuth2SessionManager;
@class RACCommand;


/**
 This view model allows to initiate OAuth authentication sequence and manages OAuth credentials using provided
 CRTCredentialStorage instance
 */
@interface CRTLoginViewModel : NSObject

- (instancetype)init __attribute__((unavailable("Use -initWithClient: instead")));

- (instancetype)initWithClient:(GROAuth2SessionManager *)client
             credentialStorage:(id <CRTCredentialStorage>)credentialStorage;


- (void)doLogout;

/// After executing this command user will be redirected to SoundCloud Connect page
@property (nonatomic, strong, readonly) RACCommand *startLogin;

/// This property is KVO-compatible
@property (nonatomic, readonly) BOOL hasCredential;

@property  (nonatomic, strong, readonly) RACSignal *loading;

/// Sends an error every time OAuth token fetching fails
@property (nonatomic, strong, readonly) RACSignal *errors;

@end

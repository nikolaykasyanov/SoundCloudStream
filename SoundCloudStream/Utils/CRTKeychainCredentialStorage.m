//
//  CRTKeychainCredentialStorage.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 18.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTKeychainCredentialStorage.h"

#import <GROAuth2SessionManager/AFOAuthCredential.h>


@implementation CRTKeychainCredentialStorage

- (AFOAuthCredential *)credentialForKey:(NSString *)key
{
    NSCParameterAssert(key != nil);

    return [AFOAuthCredential retrieveCredentialWithIdentifier:key];
}

- (void)deleteCredentialForKey:(NSString *)key
{
    NSCParameterAssert(key != nil);

    [AFOAuthCredential deleteCredentialWithIdentifier:key];
}

- (void)setCredential:(AFOAuthCredential *)credential forKey:(NSString *)key
{
    NSCParameterAssert(credential != nil);
    NSCParameterAssert(key != nil);

    [AFOAuthCredential storeCredential:credential withIdentifier:key];
}

@end

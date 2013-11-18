//
//  CRTDictionaryCredentialStorage.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 18.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTDictionaryCredentialStorage.h"


@implementation CRTDictionaryCredentialStorage {
    NSMutableDictionary *_store;
}

- (id)init
{
    self = [super init];

    if (self != nil) {
        _store = [NSMutableDictionary dictionary];
    }

    return self;
}

- (AFOAuthCredential *)credentialForKey:(NSString *)key
{
    NSCParameterAssert(key != nil);

    return _store[key];
}

- (void)deleteCredentialForKey:(NSString *)key
{
    NSCParameterAssert(key != nil);

    [_store removeObjectForKey:key];
}

- (void)setCredential:(AFOAuthCredential *)credential forKey:(NSString *)key
{
    NSCParameterAssert(key != nil);

    _store[key] = credential;
}

@end

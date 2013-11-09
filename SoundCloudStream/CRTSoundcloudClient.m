//
//  CRTSoundcloudClient.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudClient.h"


@implementation CRTSoundcloudCursor
- (instancetype)initWithLimit:(NSUInteger)limit uuid:(NSUUID *)uuid
{
    NSCParameterAssert(uuid != nil);

    self = [super init];

    if (self) {
        _limit = limit;
        _uuid = uuid;
    }

    return self;
}

+ (instancetype)cursorWithLimit:(NSUInteger)limit uuid:(NSUUID *)uuid
{
    return [[self alloc] initWithLimit:limit uuid:uuid];
}

@end


@implementation CRTSoundcloudClient

@end

//
// Created by Nikolay Kasyanov on 09.11.13.
// Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//


#import "CRTSoundcloudTrack.h"


@implementation CRTSoundcloudTrack


+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
            @"identifier" : @"id",
            @"title" : @"title",
            @"waveformURL" : @"waveform_url",
    };
}

+ (NSValueTransformer *)waveformURLJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSURL *(NSString *urlString) {
        return [NSURL URLWithString:urlString];
    }
    reverseBlock:^id(NSURL *url) {
        return url.absoluteString;
    }];
}


@end

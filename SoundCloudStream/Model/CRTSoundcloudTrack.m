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
            @"permalinkURL" : @"permalink_url",
    };
}

+ (NSValueTransformer *)waveformURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)permalinkURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}


@end

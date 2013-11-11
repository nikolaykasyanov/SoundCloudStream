//
//  CRTSoundcloudActivity.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 10.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudActivity.h"
#import "CRTSoundcloudTrack.h"

@implementation CRTSoundcloudActivity

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
            @"activityType" : @"type",
            @"origin" : @"origin"
    };
}

+ (NSValueTransformer *)activityTypeJSONTransformer
{
    NSValueTransformer *simpleMapper = [MTLValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"track" : @(CRTSoundcloudTrackActivity),
    }];

    return [MTLValueTransformer transformerWithBlock:^NSNumber *(NSString *typeString) {
        NSNumber *mappedValue = [simpleMapper transformedValue:typeString];

        if (mappedValue == nil) {
            mappedValue = @(CRTSoundcloudUnsupportedActivity);
        }

        return mappedValue;
    }];
}

+ (NSValueTransformer *)originJSONTransformer
{
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CRTSoundcloudTrack class]];
}

@end

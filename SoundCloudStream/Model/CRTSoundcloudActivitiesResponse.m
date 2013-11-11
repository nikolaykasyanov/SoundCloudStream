//
//  CRTSoundcloudActivitiesResponse.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudActivitiesResponse.h"
#import "CRTSoundcloudActivity.h"

@implementation CRTSoundcloudActivitiesResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"nextURL" : @"next_href",
             @"futureURL" : @"future_href",
             @"collection" : @"collection",
    };
}

+ (NSValueTransformer *)nextURLJSONTransformer
{
    return [MTLValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)futureURLJSONTransformer
{
    return [MTLValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)collectionJSONTransformer
{
    return [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[CRTSoundcloudActivity class]];
}

@end

//
//  CRTSoundcloudActivity.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 10.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudActivity.h"
#import "CRTSoundcloudTrack.h"


@implementation CRTSoundcloudActivityID {
    uint64_t _originIdentifier;
    CRTSoundcloudActivityType _activityType;
}

- (instancetype)initWithOriginIdentifier:(uint64_t)originIdentifier
                            activityType:(CRTSoundcloudActivityType)activityType
{
    self = [super init];
    if (self) {
        _originIdentifier = originIdentifier;
        _activityType = activityType;
    }

    return self;
}

+ (instancetype)identifierWithOriginIdentifier:(uint64_t)originIdentifier
                                  activityType:(CRTSoundcloudActivityType)activityType
{
    return [[self alloc] initWithOriginIdentifier:originIdentifier activityType:activityType];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    // we're immutable
    return self;
}

#pragma mark - Equality and hash

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToId:other];
}

- (BOOL)isEqualToId:(CRTSoundcloudActivityID *)activityID
{
    if (self == activityID)
        return YES;
    if (activityID == nil)
        return NO;
    if (_originIdentifier != activityID->_originIdentifier)
        return NO;
    if (_activityType != activityID->_activityType)
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    // identifier could not fit in NSUInteger on 32-bit platform,
    // let's just box the value and use object hash
    NSUInteger hash = @(_originIdentifier).hash;
    hash = hash * 31u + (NSUInteger) _activityType;
    return hash;
}


@end


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

- (CRTSoundcloudActivityID *)uniqueIdentifier
{
    if (self.activityType == CRTSoundcloudUnsupportedActivity) {
        return nil;
    }

    uint64_t originIdentifier = self.origin.identifier;

    NSCAssert(originIdentifier != 0, @"Invalid origin identifier but activity type is supported");

    return [CRTSoundcloudActivityID identifierWithOriginIdentifier:originIdentifier
                                                      activityType:self.activityType];
}


@end

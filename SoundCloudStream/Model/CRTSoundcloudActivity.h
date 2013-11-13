//
//  CRTSoundcloudActivity.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 10.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Mantle/Mantle.h>


typedef enum : NSUInteger {
    CRTSoundcloudUnsupportedActivity,
    CRTSoundcloudTrackActivity,
} CRTSoundcloudActivityType;


@interface CRTSoundcloudActivityID : NSObject <NSCopying>

- (instancetype)initWithOriginIdentifier:(uint64_t)originIdentifier
                            activityType:(CRTSoundcloudActivityType)activityType;

+ (instancetype)identifierWithOriginIdentifier:(uint64_t)originIdentifier
                                  activityType:(CRTSoundcloudActivityType)activityType;


@end


@protocol CRTSoundcloudActivityOrigin <NSObject>

- (uint64_t)identifier;

@end


@interface CRTSoundcloudActivity : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) CRTSoundcloudActivityType activityType;

@property (nonatomic, strong, readonly) id <CRTSoundcloudActivityOrigin> origin;

- (CRTSoundcloudActivityID *)uniqueIdentifier;

@end

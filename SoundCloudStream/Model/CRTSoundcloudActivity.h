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


@interface CRTSoundcloudActivity : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) CRTSoundcloudActivityType activityType;

@property (nonatomic, strong, readonly) id origin;

@end

//
// Created by Nikolay Kasyanov on 09.11.13.
// Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "CRTSoundcloudActivity.h"


@interface CRTSoundcloudTrack : MTLModel <MTLJSONSerializing, CRTSoundcloudActivityOrigin>

@property (nonatomic, readonly) uint64_t identifier;

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, strong, readonly) NSURL *waveformURL;
@property (nonatomic, strong, readonly) NSURL *permalinkURL;

@end

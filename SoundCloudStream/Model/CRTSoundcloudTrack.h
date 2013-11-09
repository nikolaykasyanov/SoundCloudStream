//
// Created by Nikolay Kasyanov on 09.11.13.
// Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>


@interface CRTSoundcloudTrack : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) uint64_t identifier;

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, strong, readonly) NSURL *waveformURL;

@end

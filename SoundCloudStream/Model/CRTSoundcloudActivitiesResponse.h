//
//  CRTSoundcloudActivitiesResponse.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Mantle/Mantle.h>


@interface CRTSoundcloudActivitiesResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSURL *nextURL;
@property (nonatomic, strong, readonly) NSURL *futureURL;

/** NSArray[CRTSoundcloudActivity] */
@property (nonatomic, copy, readonly) NSArray *collection;

@end

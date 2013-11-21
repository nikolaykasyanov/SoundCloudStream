//
//  constants.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const CRTSoundcloudURLScheme;

extern NSString *const CRTSoundcloudConnectURLString;
extern NSString *const CRTSoundcloudEndpointURLString;

extern NSString *const CRTSoundcloudClientID;
extern NSString *const CRTSoundcloudSecret;

extern NSString *const CRTSoundcloudBackURLString;

#pragma mark - Keychain keys

extern NSString *const CRTSoundcloudCredentialsKey;

#pragma mark - Notifications

/// This notification should be posted from application delegate's URL handling methods
extern NSString *const CRTOpenURLNotification;
extern NSString *const CRTOpenURLNotificationURLKey;

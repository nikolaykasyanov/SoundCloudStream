//
//  constants.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "constants.h"

NSString *const CRTSoundcloudURLScheme = @"ru.corristo.soundcloudstream";

NSString *const CRTSoundcloudConnectURLString = @"http://soundcloud.com/connect";
NSString *const CRTSoundcloudEndpointURLString = @"https://api.soundcloud.com/";

NSString *const CRTSoundcloudClientID = @"d2ca18cb9684ed9303a2117d58c9c8cb";
NSString *const CRTSoundcloudSecret = @"30234e3342c525804f93cc96ab0758a4";

NSString *const CRTSoundcloudBackURLString = @"ru.corristo.soundcloudstream://authCallback";

#pragma mark - Keychain keys

NSString *const CRTSoundcloudCredentialsKey = @"CRTSoundcloudCredentialsKey";

#pragma mark - Notifications

NSString *const CRTOpenURLNotification = @"CRTOpenURLNotification";
NSString *const CRTOpenURLNotificationURLKey = @"CRTOpenURLNotificationURLKey";

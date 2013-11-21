//
//  CRTSoundcloudClient.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <GROAuth2SessionManager/GROAuth2SessionManager.h>


/// This class supports OAuth 2 authentication and some SoundCloud API requests.
@interface CRTSoundcloudClient : GROAuth2SessionManager

/**
 Subscribing to this signal will trigger loading of items from /me/activities/tracks/affiliated resource
 using given limit as a "limit" GET parameter value.

 @return RACSignal[CRTSoundcloudActivitiesResponse] multicasted signal with response
 */
- (RACSignal *)affiliatedTracksWithLimit:(NSUInteger)limit;

/**
 Subscribing to this signal will loaded contents of given URL. Note that host and scheme of URL must match host and
 scheme of instance's baseURL host and scheme.

 This method is useful for iterating through collections using next_url and future_url from iterable collections responses.

 @return RACSignal[?] multicasted signal with items from given URL
 */
- (RACSignal *)collectionFromURL:(NSURL *)cursorURL;

@end

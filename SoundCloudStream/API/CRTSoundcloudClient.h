//
//  CRTSoundcloudClient.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <GROAuth2SessionManager/GROAuth2SessionManager.h>


@interface CRTSoundcloudClient : GROAuth2SessionManager

- (RACSignal *)affiliatedTracksWithLimit:(NSUInteger)limit;

- (RACSignal *)collectionFromURL:(NSURL *)cursorURL;

@end

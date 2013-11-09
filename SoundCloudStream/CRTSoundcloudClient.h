//
//  CRTSoundcloudClient.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <GROAuth2SessionManager/GROAuth2SessionManager.h>


@interface CRTSoundcloudCursor : NSObject

- (instancetype)initWithLimit:(NSUInteger)limit uuid:(NSUUID *)uuid;
+ (instancetype)cursorWithLimit:(NSUInteger)limit uuid:(NSUUID *)uuid;

@property (nonatomic, readonly) NSUInteger limit;
@property (nonatomic, strong, readonly) NSUUID *uuid;

@end


@interface CRTSoundcloudClient : GROAuth2SessionManager

- (RACSignal *)activitiesWithLimit:(NSUInteger)limit cursor:(CRTSoundcloudCursor *)cursor;
- (RACSignal *)futuresActivitiesWithLimit:(NSUInteger)limit udid:(CRTSoundcloudCursor *)udid;

@end

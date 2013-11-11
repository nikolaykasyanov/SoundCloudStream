//
//  CRTSoundcloudActivityTests.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudActivity.h"
#import "CRTSoundcloudTrack.h"


@interface CRTSoundcloudActivityTests : XCTestCase

@end

@implementation CRTSoundcloudActivityTests

- (void)testTrackActivityDeserialization
{
    NSDictionary *rawActivity = [self crt_jsonFromResourse:@"track_activity"];

    NSError *mantleError = nil;
    CRTSoundcloudActivity *activity = [MTLJSONAdapter modelOfClass:[CRTSoundcloudActivity class]
                                                fromJSONDictionary:rawActivity
                                                             error:&mantleError];

    XCTAssertNotNil(activity, @"Mantle cannot instantiate a model: %@", mantleError);

    XCTAssertEqual(activity.activityType, CRTSoundcloudTrackActivity, @"Unexpected activity type");
    XCTAssertTrue([activity.origin isKindOfClass:[CRTSoundcloudTrack class]], @"Origin of unexpected class");
}

- (void)testUnsupportedActivityDeserialization
{
    NSDictionary *rawActivity = [self crt_jsonFromResourse:@"playlist_activity"];

    NSError *mantleError = nil;
    CRTSoundcloudActivity *activity = [MTLJSONAdapter modelOfClass:[CRTSoundcloudActivity class]
                                                fromJSONDictionary:rawActivity
                                                             error:&mantleError];

    XCTAssertNotNil(activity, @"Mantle cannot instantiate a model: %@", mantleError);
    XCTAssertEqual(activity.activityType, CRTSoundcloudUnsupportedActivity, @"Unexpected activity type");
}

@end

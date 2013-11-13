//
//  CRTSoundcloudActivityID.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 13.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudActivity.h"


@interface CRTSoundcloudActivityIDTests : XCTestCase

@end


@implementation CRTSoundcloudActivityIDTests

- (void)testEqualityAndHash
{
    id firstIdentifier = [CRTSoundcloudActivityID identifierWithOriginIdentifier:12345
                                                                    activityType:CRTSoundcloudTrackActivity];

    id secondIdentifier = [CRTSoundcloudActivityID identifierWithOriginIdentifier:12345
                                                                     activityType:CRTSoundcloudTrackActivity];

    XCTAssertEqualObjects(firstIdentifier, secondIdentifier, @"Objects are not equal");
    XCTAssertEqual([firstIdentifier hash], [secondIdentifier hash], @"Hashes do not match");

    id thirdIdentifier = [CRTSoundcloudActivityID identifierWithOriginIdentifier:1
                                                                    activityType:CRTSoundcloudTrackActivity];

    XCTAssertNotEqualObjects(firstIdentifier, thirdIdentifier, @"Different objects are equal");

    id fourthIdentifier = [CRTSoundcloudActivityID identifierWithOriginIdentifier:12345
                                                                     activityType:CRTSoundcloudUnsupportedActivity];

    XCTAssertNotEqualObjects(firstIdentifier, fourthIdentifier, @"Different objects are equal");
}

- (void)testCopying
{
    id firstIdentifier = [CRTSoundcloudActivityID identifierWithOriginIdentifier:12345
                                                                    activityType:CRTSoundcloudTrackActivity];

    id secondIdentifier = [firstIdentifier copy];

    XCTAssertEqual(firstIdentifier, secondIdentifier, @"-copy returned unexpected object");
}

@end

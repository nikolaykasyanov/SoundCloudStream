//
//  CRTSoundcloudTrackTests.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudTrack.h"


@interface CRTSoundcloudTrackTests : XCTestCase

@end


@implementation CRTSoundcloudTrackTests

- (void)testDeserialization
{
    NSDictionary *rawTrack = [self crt_jsonFromResourse:@"track"];

    NSError *mantleError = nil;
    CRTSoundcloudTrack *track = [MTLJSONAdapter modelOfClass:[CRTSoundcloudTrack class]
                                          fromJSONDictionary:rawTrack
                                                       error:&mantleError];

    XCTAssertEqual(track.identifier, 113344484ull, @"Unexpected track id");
    XCTAssertEqualObjects(track.title, @"Giana Sisters Twisted Dreams - Main Theme", @"Unexpected track title");
    XCTAssertEqualObjects(track.waveformURL.absoluteString, @"https://w1.sndcdn.com/Vp8KRJBSzt1i_m.png", @"Unexpected waveform URL");
}

@end

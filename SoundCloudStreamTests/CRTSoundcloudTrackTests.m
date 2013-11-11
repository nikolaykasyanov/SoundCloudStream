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

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testDeserialization
{
    NSBundle *testBundle = [NSBundle bundleForClass:self.class];

    NSURL *fixtureURL = [testBundle URLForResource:@"track" withExtension:@"json"];

    NSData *jsonData = [NSData dataWithContentsOfURL:fixtureURL];

    XCTAssertNotNil(jsonData, @"Cannot load fixture");

    NSError *jsonError = nil;
    NSDictionary *rawTrack = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:0
                                                               error:&jsonError];

    XCTAssertNotNil(rawTrack, @"JSON deserialization error: %@", jsonError);

    NSError *mantleError = nil;
    CRTSoundcloudTrack *track = [MTLJSONAdapter modelOfClass:[CRTSoundcloudTrack class]
                                          fromJSONDictionary:rawTrack
                                                       error:&mantleError];

    XCTAssertEqual(track.identifier, 113344484ull, @"Unexpected track id");
    XCTAssertEqualObjects(track.title, @"Giana Sisters Twisted Dreams - Main Theme", @"Unexpected track title");
    XCTAssertEqualObjects(track.waveformURL.absoluteString, @"https://w1.sndcdn.com/Vp8KRJBSzt1i_m.png", @"Unexpected waveform URL");
}

@end

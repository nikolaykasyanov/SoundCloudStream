//
//  CRTSoundcloudActivitiesResponseTests.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//


#import "CRTSoundcloudActivitiesResponse.h"
#import "CRTSoundcloudActivity.h"


@interface CRTSoundcloudActivitiesResponseTests : XCTestCase

@end

@implementation CRTSoundcloudActivitiesResponseTests

- (void)testDeserialization
{
    NSDictionary *rawResponse = [self crt_jsonFromResourse:@"activities"];

    NSError *mantleError = nil;
    CRTSoundcloudActivitiesResponse *response = [MTLJSONAdapter modelOfClass:[CRTSoundcloudActivitiesResponse class]
                                                          fromJSONDictionary:rawResponse
                                                                       error:&mantleError];

    XCTAssertNotNil(response, @"Mantle cannot instantiate a model: %@", mantleError);
    XCTAssertEqual(response.collection.count, 5u, @"Invalid collection count");

    for (id item in response.collection) {
        XCTAssertTrue([item isKindOfClass:[CRTSoundcloudActivity class]], @"Item of unexpected class in response collection");
    }

    XCTAssertEqualObjects(response.futureURL.absoluteString, @"https://api.soundcloud.com/me/activities?limit=5&uuid%5Bto%5D=0eeba780-2a97-11e3-8043-5601b8bc2174", @"Unexpected future URL");
    XCTAssertEqualObjects(response.nextURL.absoluteString, @"https://api.soundcloud.com/me/activities?cursor=6c90e400-0052-11e3-8027-ab9f4b1e8d32&limit=5", @"Unexpected next URL");
}

@end

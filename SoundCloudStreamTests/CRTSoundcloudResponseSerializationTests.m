//
//  CRTSoundcloudResponseSerializationTests.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudResponseSerialization.h"
#import "CRTSoundcloudActivitiesResponse.h"


@interface CRTSoundcloudResponseSerializationTests : XCTestCase

@property (nonatomic, strong) CRTSoundcloudResponseSerialization *serializer;

@end


@implementation CRTSoundcloudResponseSerializationTests

- (void)setUp
{
    [super setUp];

    NSDictionary *mapping = @{
                              @"/me/activities" : [CRTSoundcloudActivitiesResponse class],
                              };

    self.serializer = [[CRTSoundcloudResponseSerialization alloc] initWithPathMapping:mapping];
}

- (void)tearDown
{
    self.serializer = nil;

    [super tearDown];
}

- (void)testMappedPathDeserialization
{
    NSURL *url = [NSURL URLWithString:@"http://api.soundcloud.com/me/activities/tracks/affiliated.json"];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{
                                                                           @"Content-Type": @"application/json"}];

    NSData *jsonData = [self crt_dataFromResourse:@"activities" extension:@"json"];

    NSError *responseError = nil;
    id responseObject = [self.serializer responseObjectForResponse:response data:jsonData error:&responseError];

    XCTAssertNotNil(responseObject, @"Cannot deserialize response: %@", responseError);

    XCTAssertTrue([responseObject isKindOfClass:[CRTSoundcloudActivitiesResponse class]], @"Unexpected response class");
}

- (void)testUnknownPathDeserialization
{
    NSDictionary *testData = @{ @"someKey" : @"Some value" };

    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:testData options:0 error:&jsonError];

    NSURL *url = [NSURL URLWithString:@"http://api.soundcloud.com/unknown/path.json"];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{
                                                                           @"Content-Type": @"application/json"}];

    NSError *responseError = nil;
    id responseObject = [self.serializer responseObjectForResponse:response
                                                              data:jsonData
                                                             error:&responseError];

    XCTAssertNotNil(responseObject, @"Cannot deserialize response: %@", responseError);

    XCTAssertEqualObjects(responseObject, testData, @"Unexpected response object");
}

@end

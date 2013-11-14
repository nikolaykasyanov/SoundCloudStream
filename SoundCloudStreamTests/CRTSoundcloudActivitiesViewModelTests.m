//
//  CRTSoundcloudActivitiesViewModelTests.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 13.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "CRTSoundcloudActivitiesViewModel.h"
#import "CRTSoundcloudClient.h"
#import "constants.h"


static const NSUInteger PageSize = 5;
static NSString *const MarkHeader = @"X-CRT-Test";

@interface CRTSoundcloudActivitiesViewModelTests : XCTestCase

@property (nonatomic, strong) CRTSoundcloudClient *client;
@property (nonatomic, strong) CRTSoundcloudActivitiesViewModel *viewModel;

@property (nonatomic, copy) NSString *markHeaderValue;

@end


static OHHTTPStubsResponse *JSONResponseFromResource(NSBundle *bundle, NSString *resource)
{
    NSString *path = [bundle pathForResource:resource ofType:nil];

    return [OHHTTPStubsResponse responseWithFileAtPath:path
                                            statusCode:200
                                               headers:@{
                                                       @"Content-Type" : @"application/json"
                                               }];
}


@implementation CRTSoundcloudActivitiesViewModelTests

- (void)setUp
{
    [super setUp];

    NSURL *endpointURL = [NSURL URLWithString:CRTSoundcloudEndpointURLString];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [OHHTTPStubs setEnabled:YES forSessionConfiguration:sessionConfiguration];

    self.client = [[CRTSoundcloudClient alloc] initWithBaseURL:endpointURL sessionConfiguration:sessionConfiguration];

    NSNumber *tag = @(arc4random());
    self.markHeaderValue = tag.stringValue;

    [self.client.requestSerializer setValue:self.markHeaderValue forHTTPHeaderField:MarkHeader];

    self.viewModel = [[CRTSoundcloudActivitiesViewModel alloc] initWithAPIClient:self.client pageSize:PageSize];
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];

    [super tearDown];
}

- (void)testFirstAndSecondPageFetch
{
    id firstStub =
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.allHTTPHeaderFields[MarkHeader] isEqualToString:self.markHeaderValue];
        }
        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return JSONResponseFromResource(self.crt_testBundle, @"first.json");
        }];

    __block NSArray *itemsFromPages = nil;
    [self.viewModel.pages subscribeNext:^(NSArray *items) {
        itemsFromPages = items;
    }];

    BOOL completed = [[self.viewModel.loadNextPage execute:nil] asynchronouslyWaitUntilCompleted:NULL];

    NSUInteger numberOfItemsOn1StPage = itemsFromPages.count;

    XCTAssertTrue(completed);
    XCTAssertEqual(itemsFromPages.count, (NSUInteger) 5);
    XCTAssertEqual(self.viewModel.numberOfActivities, itemsFromPages.count);
    XCTAssertTrue(self.viewModel.loadNextPage.enabled.first, @"Next page cannot be loaded");

    [OHHTTPStubs removeStub:firstStub];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.allHTTPHeaderFields[MarkHeader] isEqualToString:self.markHeaderValue] &&
                [request.URL.absoluteString isEqualToString:self.viewModel.nextCursor.absoluteString];
    }
    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return JSONResponseFromResource(self.crt_testBundle, @"second.json");
    }];

    completed = [[self.viewModel.loadNextPage execute:nil] asynchronouslyWaitUntilCompleted:NULL];

    XCTAssertTrue(completed);
    XCTAssertEqual(itemsFromPages.count, (NSUInteger) 1);
    XCTAssertEqual(self.viewModel.numberOfActivities, itemsFromPages.count + numberOfItemsOn1StPage);
    XCTAssertFalse([self.viewModel.loadNextPage.enabled.first boolValue], @"Next page can be loaded");
}

@end

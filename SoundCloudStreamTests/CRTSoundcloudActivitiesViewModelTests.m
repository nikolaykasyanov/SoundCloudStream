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
static const NSUInteger MinInvisibleItems = 2;
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

static OHHTTPStubsResponse *JSONResponseWithError()
{
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                         code:NSURLErrorNetworkConnectionLost
                                     userInfo:nil];

    return [OHHTTPStubsResponse responseWithError:error];
}


@implementation CRTSoundcloudActivitiesViewModelTests

- (id <OHHTTPStubsDescriptor>)stubFirstPage
{
    return
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.allHTTPHeaderFields[MarkHeader] isEqualToString:self.markHeaderValue];
        }
        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return JSONResponseFromResource(self.crt_testBundle, @"first.json");
        }];
}

- (id <OHHTTPStubsDescriptor>)stubNextPage
{
    return
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.allHTTPHeaderFields[MarkHeader] isEqualToString:self.markHeaderValue] &&
                    [request.URL.absoluteString isEqualToString:self.viewModel.nextCursor.absoluteString];
        }
        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return JSONResponseFromResource(self.crt_testBundle, @"second.json");
        }];
}

- (id <OHHTTPStubsDescriptor>)stubNextPageWithError
{
    return
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.allHTTPHeaderFields[MarkHeader] isEqualToString:self.markHeaderValue] &&
                    [request.URL.absoluteString isEqualToString:self.viewModel.nextCursor.absoluteString];
        }
        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return JSONResponseWithError();
        }];
}

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

    self.viewModel = [[CRTSoundcloudActivitiesViewModel alloc] initWithAPIClient:self.client
                                                                        pageSize:PageSize
                                                               minInvisibleItems:MinInvisibleItems];
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];

    [super tearDown];
}

- (void)testFirstAndSecondPageFetch
{
    id firstStub = [self stubFirstPage];

    __block NSArray *itemsFromPages = nil;
    [self.viewModel.pages subscribeNext:^(NSArray *items) {
        itemsFromPages = items;
    }];

    BOOL completed = [[self.viewModel.loadNextPage execute:nil] asynchronouslyWaitUntilCompleted:NULL];
    [OHHTTPStubs removeStub:firstStub];

    NSUInteger numberOfItemsOn1StPage = itemsFromPages.count;

    XCTAssertTrue(completed);
    XCTAssertEqual(itemsFromPages.count, (NSUInteger) 5);
    XCTAssertEqual(self.viewModel.numberOfActivities, itemsFromPages.count);
    XCTAssertTrue(self.viewModel.loadNextPage.enabled.first, @"Next page cannot be loaded");

    NSArray *itemsFromFirstPage = itemsFromPages;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.allHTTPHeaderFields[MarkHeader] isEqualToString:self.markHeaderValue] &&
                [request.URL.absoluteString isEqualToString:self.viewModel.nextCursor.absoluteString];
    }
    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return JSONResponseFromResource(self.crt_testBundle, @"second.json");
    }];

    completed = [[self.viewModel.loadNextPage execute:nil] asynchronouslyWaitUntilCompleted:NULL];

    NSArray *itemsFromSecondPage = itemsFromPages;

    XCTAssertTrue(completed);
    XCTAssertEqual(itemsFromPages.count, (NSUInteger) 1);
    XCTAssertEqual(self.viewModel.numberOfActivities, itemsFromPages.count + numberOfItemsOn1StPage);

    for (NSUInteger index = 0; index < itemsFromFirstPage.count; index++) {
        XCTAssertEqualObjects([self.viewModel activityAtIndex:index], itemsFromFirstPage[index], @"Current view model activities array should start with first page items");
    }

    for (NSUInteger index = 0; index < itemsFromSecondPage.count; index++) {
        NSUInteger viewModelIndex = itemsFromFirstPage.count + index;
        XCTAssertEqualObjects([self.viewModel activityAtIndex:viewModelIndex], itemsFromSecondPage[index], @"Current view model activities array should end with second page items");
    }

    XCTAssertFalse([self.viewModel.loadNextPage.enabled.first boolValue], @"Next page can be loaded");
}

- (void)testVisibleRangeTriggeredLoading
{
    id firstStub = [self stubFirstPage];

    BOOL completed = [[self.viewModel.loadNextPage execute:nil] asynchronouslyWaitUntilCompleted:NULL];
    [OHHTTPStubs removeStub:firstStub];

    XCTAssertTrue(completed);


    [self stubNextPage];

    NSRange initialRange =  NSMakeRange(0, self.viewModel.numberOfActivities - MinInvisibleItems);
    XCTAssertFalse([self.viewModel updateVisibleRange:initialRange], @"Next page should not start loading with given visible range");

    NSRange nextRange = NSMakeRange(initialRange.location + 1, initialRange.length);

    XCTAssertTrue([self.viewModel updateVisibleRange:nextRange], @"Next page should start loading after updaring range visible range");
}

- (void)testVisibleRangeTriggeredLoadingAfterError
{
    id firstStub = [self stubFirstPage];

    BOOL completed = [[self.viewModel.loadNextPage execute:nil] asynchronouslyWaitUntilCompleted:NULL];
    [OHHTTPStubs removeStub:firstStub];

    XCTAssertTrue(completed);

    [self stubNextPageWithError];

    NSRange range = NSMakeRange(0, self.viewModel.numberOfActivities - MinInvisibleItems + 1);

    XCTAssertTrue([self.viewModel updateVisibleRange:range], @"Next page should start loading after updaring range visible range");

    // wait until we receive some error
    BOOL errorOccurred = NO;
    [self.viewModel.errors asynchronousFirstOrDefault:nil
                                              success:&errorOccurred
                                                error:nil];

    XCTAssertTrue(errorOccurred);

    NSRange nextRange = NSMakeRange(1, range.length);

    XCTAssertFalse([self.viewModel updateVisibleRange:nextRange], @"Next page should start loading after updaring range visible range");
}

@end

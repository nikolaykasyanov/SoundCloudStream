//
//  CRTActivitiesViewModelTests.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 13.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import <GROAuth2SessionManager/AFOAuthCredential.h>

#import "CRTLoginViewModel.h"
#import "CRTActivitiesViewModel.h"
#import "CRTSoundcloudClient.h"
#import "CRTDictionaryCredentialStorage.h"


static const NSUInteger PageSize = 5;
static const NSUInteger MinInvisibleItems = 2;
static NSString *const MarkHeader = @"X-CRT-Test";

@interface CRTActivitiesViewModelTests : XCTestCase

@property (nonatomic, strong) CRTSoundcloudClient *client;
@property (nonatomic, strong) CRTActivitiesViewModel *viewModel;

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


@implementation CRTActivitiesViewModelTests

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

- (id <OHHTTPStubsDescriptor>)stubNextPageFromURL:(NSURL *)url resource:(NSString *)resource
{
    return
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.allHTTPHeaderFields[MarkHeader] isEqualToString:self.markHeaderValue] &&
                    [request.URL.absoluteString isEqualToString:url.absoluteString];
        }
        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return JSONResponseFromResource(self.crt_testBundle, resource);
        }];
}

- (id <OHHTTPStubsDescriptor>)stubNextPageWithErrorFromURL:(NSURL *)url
{
    return
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.allHTTPHeaderFields[MarkHeader] isEqualToString:self.markHeaderValue] &&
                    [request.URL.absoluteString isEqualToString:url.absoluteString];
        }
        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return JSONResponseWithError();
        }];
}

- (void)stubFirstPageAndAssertCompletion
{
    id firstStub = [self stubFirstPage];
    BOOL completed = [[self.viewModel.loadNextPage execute:nil] asynchronouslyWaitUntilCompleted:NULL];
    [OHHTTPStubs removeStub:firstStub];

    XCTAssertTrue(completed);
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

    // let's setup activities view model with underlying authorized login view model
    CRTDictionaryCredentialStorage *credentials = [[CRTDictionaryCredentialStorage alloc] init];

    AFOAuthCredential *credential = [[AFOAuthCredential alloc] initWithOAuthToken:@"token" tokenType:@"OAuth"];
    [credentials setCredential:credential forKey:CRTSoundcloudCredentialsKey];

    CRTLoginViewModel *loginViewModel = [[CRTLoginViewModel alloc] initWithClient:self.client
                                                                credentialStorage:credentials];

    self.viewModel = [[CRTActivitiesViewModel alloc] initWithAPIClient:self.client
                                                                  loginViewModel:loginViewModel
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
    __block NSArray *itemsFromPages = nil;
    [self.viewModel.pages subscribeNext:^(NSArray *items) {
        itemsFromPages = items;
    }];

    [self stubFirstPageAndAssertCompletion];

    NSUInteger numberOfItemsOn1StPage = itemsFromPages.count;

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

    BOOL completed = [[self.viewModel.loadNextPage execute:nil] asynchronouslyWaitUntilCompleted:NULL];

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
    [self stubFirstPageAndAssertCompletion];

    [self stubNextPageFromURL:self.viewModel.nextCursor resource:@"second.json"];

    NSRange initialRange =  NSMakeRange(0, self.viewModel.numberOfActivities - MinInvisibleItems);
    XCTAssertFalse([self.viewModel updateVisibleRange:initialRange], @"Next page should not start loading with given visible range");

    NSRange nextRange = NSMakeRange(initialRange.location + 1, initialRange.length);

    XCTAssertTrue([self.viewModel updateVisibleRange:nextRange], @"Next page should start loading after updaring range visible range");
}

- (void)testVisibleRangeTriggeredLoadingAfterError
{
    [self stubFirstPageAndAssertCompletion];

    [self stubNextPageWithErrorFromURL:self.viewModel.nextCursor];

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

- (void)testRefresh
{
    NSNumber *canRefreshWhenEmpty = self.viewModel.refresh.enabled.first;
    XCTAssertFalse(canRefreshWhenEmpty.boolValue);

    [self stubFirstPageAndAssertCompletion];

    NSNumber *canRefresh = self.viewModel.refresh.enabled.first;
    XCTAssertTrue(canRefresh.boolValue);

    [self stubNextPageFromURL:self.viewModel.futureCursor resource:@"new.json"];

    __block NSArray *newItems = nil;
    [self.viewModel.freshBatches subscribeNext:^(NSArray *items) {
        newItems = items;
    }];

    BOOL completed = [[self.viewModel.refresh execute:nil] asynchronouslyWaitUntilCompleted:NULL];

    XCTAssertTrue(completed);
    XCTAssertNotNil(newItems);

    for (NSUInteger index = 0; index < newItems.count; index++) {
        XCTAssertEqualObjects([self.viewModel activityAtIndex:index], newItems[index], @"Current view model activities array should start with new items");
    }
}

- (void)testLogout
{
    [self stubFirstPageAndAssertCompletion];

    XCTAssertNotNil(self.viewModel.nextCursor);
    XCTAssertNotNil(self.viewModel.futureCursor);

    [self.viewModel.loginViewModel.logout execute:nil];

    BOOL reloadReceived = NO;
    [self.viewModel.reloads asynchronousFirstOrDefault:nil success:&reloadReceived error:NULL];

    XCTAssertTrue(reloadReceived);
    XCTAssertNil(self.viewModel.nextCursor);
    XCTAssertNil(self.viewModel.futureCursor);

    NSNumber *refreshEnabled = [[self.viewModel.refresh.enabled ignore:@YES] asynchronousFirstOrDefault:nil success:NULL error:NULL];

    XCTAssertFalse(refreshEnabled.boolValue);
}

@end

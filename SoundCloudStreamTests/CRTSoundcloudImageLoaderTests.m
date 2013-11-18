//
//  CRTSoundcloudImageLoaderTests.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 18.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "CRTSoundcloudImageLoader.h"


static NSString *const MarkHeader = @"X-CRT-Test";


@interface CRTSoundcloudImageLoaderTests : XCTestCase

@property (nonatomic, strong) CRTSoundcloudImageLoader *imageLoader;
@property (nonatomic, copy) NSString *markHeaderValue;

@end

@implementation CRTSoundcloudImageLoaderTests

- (void)setUp
{
    [super setUp];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [OHHTTPStubs setEnabled:YES forSessionConfiguration:sessionConfiguration];

    NSNumber *tag = @(arc4random());
    self.markHeaderValue = tag.stringValue;

    self.imageLoader = [[CRTSoundcloudImageLoader alloc] initWithSessionConfiguration:sessionConfiguration];
    [self.imageLoader.requestSerializer setValue:self.markHeaderValue forHTTPHeaderField:MarkHeader];
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];

    [super tearDown];
}

- (void)testImageLoading
{
    __block BOOL stubbed = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL flag = [request.allHTTPHeaderFields[MarkHeader] isEqual:self.markHeaderValue];
        return flag;
    }
    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        stubbed = YES;
        NSData *imageData = [self crt_dataFromResourse:@"waveform" extension:@"png"];
        return [OHHTTPStubsResponse responseWithData:imageData
                                          statusCode:200
                                             headers:@{
                                                       @"Content-Type": @"image/png"
                                                       }];
    }];

    NSURL *imageURL = [NSURL URLWithString:@"http://google.com/i/doodle.png"];
    RACSignal *imageSignal1 = [self.imageLoader imageFromURL:imageURL];

    BOOL success = NO;
    UIImage *image = [imageSignal1 asynchronousFirstOrDefault:nil success:&success error:NULL];

    XCTAssertTrue(stubbed, "Stub wasn't used for some reason");
    XCTAssertTrue(success);
    XCTAssertNotNil(image);

    size_t imageWidth = CGImageGetWidth(image.CGImage);
    size_t imageHeight = CGImageGetHeight(image.CGImage);

    XCTAssertEqual(imageWidth, (size_t) 1800);
    XCTAssertEqual(imageHeight, (size_t) 280);
}

@end

//
//  CRTImageLoaderTests.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 18.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CRTImageLoader.h"


static NSString *const MarkHeader = @"X-CRT-Test";
static const CGFloat MaxWaveformWidth = 320;


@interface CRTImageLoaderTests : XCTestCase

@property (nonatomic, strong) CRTImageLoader *imageLoader;
@property (nonatomic, copy) NSString *markHeaderValue;

@end

@implementation CRTImageLoaderTests

- (void)setUp
{
    [super setUp];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [OHHTTPStubs setEnabled:YES forSessionConfiguration:sessionConfiguration];

    NSNumber *tag = @(arc4random());
    self.markHeaderValue = tag.stringValue;

    self.imageLoader = [[CRTImageLoader alloc] initWithURLSessionConfiguration:sessionConfiguration
                                                                        maxWaveformWidth:MaxWaveformWidth];
    [self.imageLoader.requestSerializer setValue:self.markHeaderValue forHTTPHeaderField:MarkHeader];
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];

    [super tearDown];
}

- (void)testImageLoading
{
    // hardcode is bad, m'key
    const size_t sourceImageWidth = 1800;
    const size_t sourceImageHeight = 280;

    __block BOOL stubbed = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.allHTTPHeaderFields[MarkHeader] isEqual:self.markHeaderValue];
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
    RACSignal *imageSignal1 = [self.imageLoader waveformFromURL:imageURL];

    BOOL success = NO;
    UIImage *image = [imageSignal1 asynchronousFirstOrDefault:nil success:&success error:NULL];

    XCTAssertTrue(stubbed, "Stub wasn't used for some reason");
    XCTAssertTrue(success);
    XCTAssertNotNil(image);

    size_t expectedImageWidth = (size_t) (image.scale * MaxWaveformWidth);
    size_t expectedImageHeight = (size_t) ceil(0.5 * sourceImageHeight * (MaxWaveformWidth * image.scale) / sourceImageWidth);

    XCTAssertEqual(CGImageGetWidth(image.CGImage), (size_t) expectedImageWidth);
    XCTAssertEqual(CGImageGetHeight(image.CGImage), (size_t) expectedImageHeight);
}

@end

//
//  XCTestCase+CRTResourceLoading.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "XCTestCase+CRTResourceLoading.h"

@implementation XCTestCase (CRTResourceLoading)

- (NSBundle *)crt_testBundle
{
    return [NSBundle bundleForClass:self.class];
}

- (NSDictionary *)crt_jsonFromResourse:(NSString *)resource
{
    XCTAssertNotNil(resource, @"Resource name should not be nil");

    NSBundle *testBundle = self.crt_testBundle;

    NSURL *fixtureURL = [testBundle URLForResource:resource withExtension:@"json"];

    XCTAssertNotNil(fixtureURL, @"No resource named '%@' in bundle '%@'", resource, testBundle);

    NSData *jsonData = [NSData dataWithContentsOfURL:fixtureURL];

    XCTAssertNotNil(jsonData, @"Cannot load fixture");

    NSError *jsonError = nil;
    NSDictionary *rawActivity = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];

    XCTAssertNotNil(rawActivity, @"JSON deserialization error: %@", jsonError);

    return rawActivity;
}

@end

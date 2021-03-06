//
//  XCTestCase+CRTResourceLoading.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XCTestCase (CRTResourceLoading)

- (NSBundle *)crt_testBundle;

- (NSData *)crt_dataFromResourse:(NSString *)resource extension:(NSString *)extension;

- (NSDictionary *)crt_jsonFromResourse:(NSString *)resource;

@end

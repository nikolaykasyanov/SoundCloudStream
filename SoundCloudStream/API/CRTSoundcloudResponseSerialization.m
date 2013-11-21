//
//  CRTSoundcloudResponseSerialization.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudResponseSerialization.h"
#import <Mantle/MTLJSONAdapter.h>


NSString *const CRTSoundcloudResponseErrorDomain = @"CRTSoundcloudResponseErrorDomain";
const NSInteger CRTSoundcloudResponseErrorUnknownPath = -1;

NSString *const CRTSoundcloudResponseErrorResponseKey = @"CRTSoundcloudResponseErrorResponseKey";
NSString *const CRTSoundcloudResponseErrorRawObjectKey = @"CRTSoundcloudResponseErrorRawObjectKey";


@interface CRTSoundcloudResponseSerialization ()

@property (nonatomic, copy, readonly) NSDictionary *mapping;

@end

@implementation CRTSoundcloudResponseSerialization

- (instancetype)initWithPathMapping:(NSDictionary *)mapping
{
    NSCParameterAssert(mapping != nil);

    self = [super init];

    if (self != nil) {
        _mapping = [mapping copy];
    }

    return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    NSDictionary *jsonDictionary = [super responseObjectForResponse:response data:data error:error];

    if (jsonDictionary == nil) {
        return nil;
    }

    __block Class modelClass = Nil;
    [self.mapping enumerateKeysAndObjectsUsingBlock:^(NSString *pathPrefix, id obj, BOOL *stop) {
        if ([response.URL.path hasPrefix:pathPrefix]) {
            modelClass = obj;
            *stop = YES;
        }
    }];

    if (modelClass == Nil) {
        *error = [NSError errorWithDomain:CRTSoundcloudResponseErrorDomain
                                     code:CRTSoundcloudResponseErrorUnknownPath
                                 userInfo:@{
                                         CRTSoundcloudResponseErrorResponseKey : response,
                                         CRTSoundcloudResponseErrorRawObjectKey : jsonDictionary,
                                         NSLocalizedDescriptionKey : NSLocalizedString(@"Cannot deserialize response", @"Message about failed response deserialization"),
                                 }];
        return nil;
    }
    else {
        return [MTLJSONAdapter modelOfClass:modelClass
                         fromJSONDictionary:jsonDictionary
                                      error:error];
    }
}

@end

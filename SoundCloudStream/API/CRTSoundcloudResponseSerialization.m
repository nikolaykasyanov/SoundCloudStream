//
//  CRTSoundcloudResponseSerialization.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudResponseSerialization.h"
#import <Mantle/MTLJSONAdapter.h>


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
        NSLog(@"No matching model class for URL path %@", response.URL.path);
        return jsonDictionary;
    }
    else {
        return [MTLJSONAdapter modelOfClass:modelClass
                         fromJSONDictionary:jsonDictionary
                                      error:error];
    }
}

@end

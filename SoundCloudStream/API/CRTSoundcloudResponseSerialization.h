//
//  CRTSoundcloudResponseSerialization.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "AFURLResponseSerialization.h"


extern NSString *const CRTSoundcloudResponseErrorDomain;
extern const NSInteger CRTSoundcloudResponseErrorUnknownPath;

extern NSString *const CRTSoundcloudResponseErrorResponseKey;
extern NSString *const CRTSoundcloudResponseErrorRawObjectKey;


/**
 Instances of this class could be used as a AFHTTPSessionManager response serializer. Mapping will be used to determine
 proper model class for resource path. Only simple prefix matching is implemented now, but it could be improved with
 regexp support or something like that in the future.
 */
@interface CRTSoundcloudResponseSerialization : AFJSONResponseSerializer

/**
 Initializes response deserialization with mapping. Mapping must have type NSDictionary[NSString, Class], kind of:

 @code
 mapping = @{
     @"/me/tracks" : [CRTSoundcloudTracksResponse class],
     @"/me/comments" : [CRTSoundcloudCommentsResponse class],
     ...
 };
 @endcode
 */
- (instancetype)initWithPathMapping:(NSDictionary *)mapping;

@end

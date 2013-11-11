//
//  NSURL+CRTURLComparison.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "NSURL+CRTURLComparison.h"

@implementation NSURL (CRTURLComparison)

- (BOOL)crt_areSchemeAndHostMatchWithURL:(NSURL *)url
{
    return [self.scheme isEqualToString:url.scheme] &&
            [self.host isEqualToString:url.host];
}

@end

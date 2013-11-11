//
//  NSURL+CRTURLComparison.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 11.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (CRTURLComparison)

- (BOOL)crt_areSchemeAndHostMatchWithURL:(NSURL *)url;

@end

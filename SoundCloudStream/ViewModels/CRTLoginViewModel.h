//
//  CRTLoginViewModel.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 09.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;

@interface CRTLoginViewModel : NSObject

@property (nonatomic, strong, readonly) RACCommand *startLogin;

@property (nonatomic, copy, readonly) NSString *authToken;

@end

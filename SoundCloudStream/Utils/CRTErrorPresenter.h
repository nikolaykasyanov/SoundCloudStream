//
//  CRTErrorPresenter.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 19.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRTErrorPresenter : NSObject

- (instancetype)initWithApplicationWindow:(UIWindow *)mainWindow;

- (void)presentError:(NSError *)error;

@end

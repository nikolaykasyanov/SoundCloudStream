//
//  CRTErrorPresenter.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 19.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Presents errors in separate UIWindow using neat UIDynamics-powered animation

 Does not support interface orientations except portrait.
 Uses passed window to determine its window frame.
 Error covers status bar and navigation bar (64pt)
 */
@interface CRTErrorPresenter : NSObject

- (instancetype)initWithApplicationWindow:(UIWindow *)mainWindow;

- (void)presentError:(NSError *)error;

@end

//
//  CRTPageLoadingView.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 15.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//
#import <UIKit/UIKit.h>


@interface CRTPageLoadingView : UIView

@property (nonatomic, getter = isAnimating) BOOL animating;

@property (nonatomic) BOOL displayButton;

@property (nonatomic, strong, readonly) UIButton *button;

@end

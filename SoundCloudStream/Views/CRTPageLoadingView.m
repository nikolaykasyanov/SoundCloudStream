//
//  CRTPageLoadingView.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 15.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTPageLoadingView.h"


@interface CRTPageLoadingView ()

@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;

@end


@implementation CRTPageLoadingView
@dynamic animating;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.hidesWhenStopped = YES;
        [self addSubview:_indicator];

        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        _button.frame = self.frame;
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_button];

        RAC(_button, hidden) = [RACObserve(self, displayButton) not];
    }
    return self;
}

- (void)layoutSubviews
{
    _indicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)setAnimating:(BOOL)animating
{
    if (animating) {
        [_indicator startAnimating];
    }
    else {
        [_indicator stopAnimating];
    }
}

- (BOOL)isAnimating
{
    return [_indicator isAnimating];
}

@end

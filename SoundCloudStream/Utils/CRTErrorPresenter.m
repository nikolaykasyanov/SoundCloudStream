//
//  CRTErrorPresenter.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 19.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTErrorPresenter.h"


static const NSTimeInterval NotificationLifetime = 2.0;


@interface CRTErrorPresenter ()

@property (nonatomic, strong, readonly) UIWindow *presentingWindow;

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@property (nonatomic) NSUInteger numberOfNotifications;

@property (nonatomic, weak, readonly) UIWindow *mainWindow;

@end

@implementation CRTErrorPresenter
@synthesize presentingWindow = _presentingWindow;
@synthesize dynamicAnimator = _dynamicAnimator;

- (instancetype)initWithApplicationWindow:(UIWindow *)mainWindow
{
    NSCParameterAssert(mainWindow != nil);

    self = [super init];

    if (self != nil) {
        _mainWindow = mainWindow;
    }

    return self;
}

- (UIWindow *)presentingWindow
{
    if (_presentingWindow == nil) {
        _presentingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.mainWindow.frame), 64)];
        _presentingWindow.windowLevel = UIWindowLevelAlert;
        _presentingWindow.userInteractionEnabled = NO;
        _presentingWindow.hidden = NO;

        RAC(_presentingWindow, userInteractionEnabled) = [RACObserve(self, numberOfNotifications) map:^(NSNumber *value) {
            return @(value.unsignedIntegerValue > 0);
        }];
    }

    return _presentingWindow;
}

- (UIDynamicAnimator *)dynamicAnimator
{
    if (_dynamicAnimator == nil) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.presentingWindow];
    }

    return _dynamicAnimator;
}

- (void)presentError:(NSError *)error
{
    CGRect notificationInitialRect = { .origin = CGPointMake(0, -CGRectGetHeight(self.presentingWindow.bounds)),
                                       .size = self.presentingWindow.bounds.size };

    UIView *notificationView = [[UIView alloc] initWithFrame:notificationInitialRect];
    notificationView.backgroundColor = [UIColor colorWithRed:0.9 green:0 blue:0 alpha:1.0];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(notificationView.bounds, 5, 5)];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    textLabel.textColor = [UIColor whiteColor];
    [notificationView addSubview:textLabel];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    tapRecognizer.numberOfTapsRequired = 1;

    [notificationView addGestureRecognizer:tapRecognizer];

    [self.presentingWindow addSubview:notificationView];

    textLabel.text = error.localizedDescription;

    CGPoint snapPoint = CGPointMake(CGRectGetMidX(self.presentingWindow.bounds), CGRectGetMidY(self.presentingWindow.bounds));
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:notificationView
                                                    snapToPoint:snapPoint];
    snap.damping = 0.5;

    [self.dynamicAnimator addBehavior:snap];

    self.numberOfNotifications++;

    RACSignal *timeout = [RACSignal interval:NotificationLifetime onScheduler:[RACScheduler mainThreadScheduler]];
    RACSignal *tap = tapRecognizer.rac_gestureSignal;

    [[[RACSignal merge:@[ timeout, tap ]] take:1] subscribeCompleted:^{
        [UIView animateWithDuration:0.3 animations:^{
            notificationView.alpha = 0;
        } completion:^(BOOL finished) {
            [notificationView removeFromSuperview];

            NSCAssert(self.numberOfNotifications > 0, @"Unexpected number of notifications");
            self.numberOfNotifications--;
        }];
    }];
}

@end

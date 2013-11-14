//
//  CRTSoundcloudActivitiesViewModel.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 13.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@class CRTSoundcloudClient;
@class CRTSoundcloudActivity;
@class CRTLoginViewModel;


@interface CRTSoundcloudActivitiesViewModel : NSObject

- (instancetype)initWithAPIClient:(CRTSoundcloudClient *)client
                         pageSize:(NSUInteger)pageSize
                minInvisibleItems:(NSUInteger)minInvisibleItems;

- (CRTSoundcloudActivity *)activityAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfActivities;

- (BOOL)updateVisibleRange:(NSRange)newVisibleRange;

@property (nonatomic, strong, readonly) CRTLoginViewModel *loginViewModel;

@property (nonatomic, strong, readonly) RACCommand *loadNextPage;
@property (nonatomic, strong, readonly) RACCommand *refresh;

/** RACSignal[NSArray[CRTSoundcloudActivity] */
@property (nonatomic, strong, readonly) RACSignal *pages;

/** RACSignal[NSError] */
@property (nonatomic, strong, readonly) RACSignal *errors;

@property (nonatomic, readonly) NSRange visibleRange;

@property (nonatomic, strong, readonly) NSURL *nextCursor;
@property (nonatomic, strong, readonly) NSURL *futureCursor;

@end

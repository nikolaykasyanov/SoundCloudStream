//
//  CRTActivitiesViewModel.h
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


/**
 This is a view model for activity list. It can be used with UITableView, UICollectionView or any view that is able to
 present multiple items.
 */
@interface CRTActivitiesViewModel : NSObject

/**
 @param client API client
 @param loginViewModel used for observing "logged in"/"logged out" events
 @param pageSize maximum number of items that should be loaded in batch
 @param minInvisibleItems if number of items beyond current visible range becomes lower that this value, view model starts next page loading
 */
- (instancetype)initWithAPIClient:(CRTSoundcloudClient *)client
                   loginViewModel:(CRTLoginViewModel *)loginViewModel
                         pageSize:(NSUInteger)pageSize
                minInvisibleItems:(NSUInteger)minInvisibleItems;

- (CRTSoundcloudActivity *)activityAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfActivities;

- (BOOL)updateVisibleRange:(NSRange)newVisibleRange;

/**
 Loads waveform image from network or returns existing one from in-memory cache.
 In the latter case returned signal is synchronous.

 @param activity Track activity. If activity has other type than track, empty signal is returned
 @return RACSignal[UIImage]
 */
- (RACSignal *)waveformImageForActivity:(CRTSoundcloudActivity *)activity;

@property (nonatomic, strong, readonly) CRTLoginViewModel *loginViewModel;

/// RACSignal[CRTLoginViewModel] send a login view model instance every time view model requires authentication
@property (nonatomic, strong, readonly) RACSignal *authenticationRequests;

@property (nonatomic, strong, readonly) RACCommand *loadNextPage;
@property (nonatomic, strong, readonly) RACCommand *refresh;

/**
 This signal sends an array of activities every time page loading succeeds.
 RACSignal[NSArray[CRTSoundcloudActivity]]
 */
@property (nonatomic, strong, readonly) RACSignal *pages;

/**
 This signal sends an array of freshly loaded activities every time refresh succeeds.
 RACSignal[NSArray[CRTSoundcloudActivity]]
 */
@property (nonatomic, strong, readonly) RACSignal *freshBatches;

/** Sends `[RACUnit defaultUnit]` every time view needs to be reloaded */
@property (nonatomic, strong, readonly) RACSignal *reloads;

/**
 This signal sends an error every time page loading or refreshing fails.
 RACSignal[NSError]
 */
@property (nonatomic, strong, readonly) RACSignal *errors;

@property (nonatomic, readonly) BOOL lastPageLoadingFailed;
@property (nonatomic, readonly) BOOL hasNoActivities;

@property (nonatomic, readonly) NSRange visibleRange;

// This properties are only exposed for testing purposes. Probably they should be moved to protected methods category.
@property (nonatomic, strong, readonly) NSURL *nextCursor;
@property (nonatomic, strong, readonly) NSURL *futureCursor;

@end

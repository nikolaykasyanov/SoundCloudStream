//
//  CRTSoundcloudActivitiesViewModel.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 13.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudActivitiesViewModel.h"
#import "CRTSoundcloudClient.h"
#import "CRTSoundcloudActivity.h"
#import "CRTSoundcloudActivitiesResponse.h"
#import "CRTLoginViewModel.h"


static NSArray *FilterActuallyNewSupportedItems(NSArray *newItems, NSDictionary *existingItemsMap)
{
    NSMutableArray *actuallyNewItems = [newItems mutableCopy];

    NSUInteger currentIndex = 0;

    for (CRTSoundcloudActivity *activity in newItems) {

        id <NSCopying> key = activity.uniqueIdentifier;

        if (key == nil || existingItemsMap[key] != nil) {
            [actuallyNewItems removeObjectAtIndex:currentIndex];
        }
        else {
            currentIndex++;
        }
    }

    return actuallyNewItems;
}


@interface CRTSoundcloudActivitiesViewModel ()

/** NSArray[CRTSoundcloudActivity] */
@property (nonatomic, strong, readonly) NSMutableArray *items;

/** NSDictionary[NSNumber, CRTSoundcloudActivity] mapping identifier -> activity */
@property (nonatomic, strong, readonly) NSMutableDictionary *itemIdToItemMap;

@property (nonatomic, strong) NSURL *nextCursor;
@property (nonatomic, strong) NSURL *futureCursor;

@property (nonatomic, readonly) BOOL endOfFeedReached;

@property (nonatomic, readonly) NSUInteger pageSize;
@property (nonatomic, readonly) NSUInteger minInvisibleItems;

@property (nonatomic) BOOL lastPageLoadingFailed;

@end


@implementation CRTSoundcloudActivitiesViewModel

- (instancetype)initWithAPIClient:(CRTSoundcloudClient *)client
                         pageSize:(NSUInteger)pageSize
                minInvisibleItems:(NSUInteger)minInvisibleItems
{
    NSCParameterAssert(client != nil);
    NSCParameterAssert(pageSize > 0);
    NSCParameterAssert(minInvisibleItems <= pageSize);

    self = [super init];

    if (self == nil) {
        return nil;
    }

    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:CRTSoundcloudCredentialsKey];
    if (credential == nil) {
        _loginViewModel = [[CRTLoginViewModel alloc] initWithClient:client];

        RACSignal *futureCredential = [RACObserve(_loginViewModel, OAuthCredential) skip:1];

        RAC(self, loginViewModel) = [futureCredential mapReplace:nil];
        [client rac_liftSelector:@selector(setAuthorizationHeaderWithCredential:) withSignals:futureCredential, nil];
    }
    else {
        [client setAuthorizationHeaderWithCredential:credential];
    }

    _pageSize = pageSize;
    _minInvisibleItems = minInvisibleItems;
    _items = [NSMutableArray array];
    _itemIdToItemMap = [NSMutableDictionary dictionary];

    @weakify(self);
    _loadNextPage = [[RACCommand alloc] initWithEnabled:[RACObserve(self, endOfFeedReached) not]
                                            signalBlock:^RACSignal *(id _) {
                                                @strongify(self);

                                                if (self.nextCursor == nil) {
                                                    return [client affiliatedTracksWithLimit:pageSize];
                                                }
                                                else {
                                                    return [client collectionFromURL:self.nextCursor
                                                                        itemsOfClass:[CRTSoundcloudActivity class]];
                                                }
                                            }];

    _refresh = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal empty];
    }];

    _errors = [RACSignal merge:@[ _loadNextPage.errors, _refresh.errors ]];

    _pages = [self rac_liftSelector:@selector(clientDidLoadPage:)
                        withSignals:[_loadNextPage.executionSignals flatten], nil];

    RAC(self, endOfFeedReached) = [[[RACObserve(self, nextCursor) skip:1] map:^NSNumber *(id cursor) {
        return @(cursor == nil);
    }] startWith:@NO];

    RAC(self, lastPageLoadingFailed) = [RACSignal merge:@[
            [[_loadNextPage.executionSignals switchToLatest] mapReplace:@NO],
            [_loadNextPage.errors mapReplace:@YES],
    ]];

    return self;
}

#pragma mark - API

- (CRTSoundcloudActivity *)activityAtIndex:(NSUInteger)index
{
    NSCParameterAssert(index < self.items.count);

    return self.items[index];
}

- (NSUInteger)numberOfActivities
{
    return self.items.count;
}

- (BOOL)updateVisibleRange:(NSRange)visibleRange
{
    NSCParameterAssert(visibleRange.location + visibleRange.length <= self.items.count);

    NSUInteger olderItemsRemaining = self.items.count - (visibleRange.location + visibleRange.length);

    if (olderItemsRemaining >= self.minInvisibleItems) {
        return NO;
    }

    if (self.endOfFeedReached || self.lastPageLoadingFailed) {
        return NO;
    }

    [self.loadNextPage execute:nil];

    [self willChangeValueForKey:@keypath(self.visibleRange)];
    _visibleRange = visibleRange;
    [self didChangeValueForKey:@keypath(self.visibleRange)];

    return YES;
}

#pragma mark - Private methods

- (NSArray *)clientDidLoadPage:(CRTSoundcloudActivitiesResponse *)response
{
    NSCParameterAssert(response != nil);

    self.nextCursor = response.nextURL;

    NSArray *items = response.collection;
    NSArray *actuallyNewItems = FilterActuallyNewSupportedItems(items, self.itemIdToItemMap);

    [self.items addObjectsFromArray:actuallyNewItems];

    for (CRTSoundcloudActivity *activity in actuallyNewItems) {
        id <NSCopying> key = activity.uniqueIdentifier;
        NSCAssert(key != nil, @"Key should not be nil");
        self.itemIdToItemMap[key] = activity;
    }

    return actuallyNewItems;
}

@end

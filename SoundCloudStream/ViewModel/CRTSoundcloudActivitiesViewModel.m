//
//  CRTSoundcloudActivitiesViewModel.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 13.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudActivitiesViewModel.h"
#import "CRTSoundcloudClient.h"
#import "CRTImageLoader.h"
#import "CRTSoundcloudTrack.h"
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

@property (nonatomic, strong, readonly) NSCache *imageCache;
@property (nonatomic, strong, readonly) CRTImageLoader *imageLoader;

@end


@implementation CRTSoundcloudActivitiesViewModel

- (instancetype)initWithAPIClient:(CRTSoundcloudClient *)client
                   loginViewModel:(CRTLoginViewModel *)loginViewModel
                         pageSize:(NSUInteger)pageSize
                minInvisibleItems:(NSUInteger)minInvisibleItems
{
    NSCParameterAssert(client != nil);
    NSCParameterAssert(loginViewModel != nil);
    NSCParameterAssert(pageSize > 0);
    NSCParameterAssert(minInvisibleItems <= pageSize);

    self = [super init];

    if (self == nil) {
        return nil;
    }

    _imageCache = [[NSCache alloc] init];
    _imageLoader = [[CRTImageLoader alloc] initWithURLSessionConfiguration:nil maxWaveformWidth:320];

    _reloads = [[self rac_signalForSelector:@selector(resetContents)] mapReplace:[RACUnit defaultUnit]];

    _loginViewModel = loginViewModel;

    RACSignal *hasNoCredential = [[RACObserve(_loginViewModel, hasCredential) distinctUntilChanged] ignore:@YES];

    @weakify(self);
    [hasNoCredential subscribeNext:^(id _) {
        @strongify(self);
        [self resetContents];
    }];

    _authenticationRequests = [hasNoCredential mapReplace:_loginViewModel];

    _pageSize = pageSize;
    _minInvisibleItems = minInvisibleItems;
    _items = [NSMutableArray array];
    _itemIdToItemMap = [NSMutableDictionary dictionary];


    _loadNextPage = [[RACCommand alloc] initWithEnabled:[RACObserve(self, endOfFeedReached) not]
                                            signalBlock:^RACSignal *(id _) {
                                                @strongify(self);

                                                RACSignal *signal;
                                                if (self.nextCursor == nil) {
                                                    signal = [client affiliatedTracksWithLimit:pageSize];
                                                }
                                                else {
                                                    signal = [client collectionFromURL:self.nextCursor
                                                                        itemsOfClass:[CRTSoundcloudActivity class]];
                                                }

                                                return [signal takeUntil:hasNoCredential];
                                            }];

    _pages = [self rac_liftSelector:@selector(clientDidLoadPage:)
                        withSignals:[_loadNextPage.executionSignals flatten], nil];

    RACSignal *hasFutureCursor = [RACObserve(self, futureCursor) map:^NSNumber *(id value) {
        return @(value != nil);
    }];

    RACSignal *canRefresh = [[RACSignal combineLatest:@[
            hasFutureCursor,
            RACObserve(_loginViewModel, hasCredential),
    ]] and];

    _refresh = [[RACCommand alloc] initWithEnabled:canRefresh
                                       signalBlock:^RACSignal *(id _) {
                                           @strongify(self);

                                           return [client collectionFromURL:self.futureCursor
                                                               itemsOfClass:[CRTSoundcloudActivity class]];
                                       }];

    _freshBatches = [self rac_liftSelector:@selector(clientDidLoadNewItems:)
                               withSignals:[_refresh.executionSignals flatten], nil];

    _errors = [RACSignal merge:@[ _loadNextPage.errors, _refresh.errors ]];

    RACSignal *resetSignal = [self rac_signalForSelector:@selector(resetContents)];

    RAC(self, endOfFeedReached) = [[[[[RACObserve(self, nextCursor) skip:1] map:^NSNumber *(id cursor) {
        return @(cursor == nil);
    }] startWith:@NO] takeUntil:resetSignal] repeat];

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

- (RACSignal *)waveformImageForActivity:(CRTSoundcloudActivity *)activity
{
    if (activity.activityType != CRTSoundcloudTrackActivity) {
        return [RACSignal empty];
    }

    CRTSoundcloudTrack *track = (CRTSoundcloudTrack *) activity.origin;
    NSURL *waveformURL = track.waveformURL;

    UIImage *cachedImage = [self.imageCache objectForKey:waveformURL];
    if (cachedImage != nil) {
        return [RACSignal return:cachedImage];
    }

    return [[self.imageLoader waveformFromURL:waveformURL] doNext:^(id image) {
        [self.imageCache setObject:image forKey:waveformURL];
    }];
}

#pragma mark - Private methods

- (NSArray *)clientDidLoadPage:(CRTSoundcloudActivitiesResponse *)response
{
    NSCParameterAssert(response != nil);

    self.nextCursor = response.nextURL;
    self.futureCursor = response.futureURL;

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

- (NSArray *)clientDidLoadNewItems:(CRTSoundcloudActivitiesResponse *)response
{
    NSCParameterAssert(response != nil);

    self.futureCursor = response.futureURL;

    NSArray *items = response.collection;
    NSArray *actuallyNewItems = FilterActuallyNewSupportedItems(items, self.itemIdToItemMap);

    [self.items insertObjects:actuallyNewItems
                    atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, actuallyNewItems.count)]];

    for (CRTSoundcloudActivity *activity in actuallyNewItems) {
        id <NSCopying> key = activity.uniqueIdentifier;
        NSCAssert(key != nil, @"Key should not be nil");
        self.itemIdToItemMap[key] = activity;
    }

    return actuallyNewItems;
}

- (void)resetContents
{
    self.nextCursor = self.futureCursor = nil;

    [self.items removeAllObjects];
    [self.itemIdToItemMap removeAllObjects];
}

@end

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


@interface CRTSoundcloudActivitiesViewModel ()

/** NSArray[CRTSoundcloudActivity] */
@property (nonatomic, strong, readonly) NSMutableArray *items;

/** NSDictionary[NSNumber, CRTSoundcloudActivity] mapping identifier -> activity */
@property (nonatomic, strong, readonly) NSMutableDictionary *itemIdToItemMap;

@property (nonatomic, strong) NSURL *nextCursor;
@property (nonatomic, strong) NSURL *futureCursor;

@property (nonatomic, readonly) BOOL endOfFeedReached;

@end


@implementation CRTSoundcloudActivitiesViewModel

- (instancetype)initWithAPIClient:(CRTSoundcloudClient *)client pageSize:(NSUInteger)pageSize
{
    NSCParameterAssert(client != nil);
    NSCParameterAssert(pageSize > 0);

    self = [super init];

    if (self != nil) {
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

        _errors = [RACSignal combineLatest:@[ _loadNextPage.errors, _refresh.errors ]];

        _pages = [self rac_liftSelector:@selector(clientDidLoadResponse:)
                            withSignals:[_loadNextPage.executionSignals flatten], nil];

        RAC(self, endOfFeedReached) = [[[RACObserve(self, nextCursor) skip:1] map:^NSNumber *(id cursor) {
            return @(cursor == nil);
        }] startWith:@NO].logAll;
    }

    return self;
}

- (CRTSoundcloudActivity *)activityAtIndex:(NSUInteger)index
{
    NSCParameterAssert(index < self.items.count);

    return self.items[index];
}

- (NSUInteger)numberOfActivities
{
    return self.items.count;
}

- (NSArray *)clientDidLoadResponse:(CRTSoundcloudActivitiesResponse *)response
{
    NSCParameterAssert(response != nil);

    self.nextCursor = response.nextURL;

    NSArray *items = response.collection;

    NSMutableArray *newItems = [items mutableCopy];

    NSUInteger currentIndex = 0;

    for (CRTSoundcloudActivity *activity in items) {

        id <NSCopying> key = activity.uniqueIdentifier;

        if (key == nil || self.itemIdToItemMap[key] != nil) {
            [newItems removeObjectAtIndex:currentIndex];
        }
        else {
            [self.items addObject:activity];
            self.itemIdToItemMap[key] = activity;
            currentIndex++;
        }
    }

    return [newItems copy];
}

@end

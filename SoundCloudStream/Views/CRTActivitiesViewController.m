//
//  CRTActivitiesViewController.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 14.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTActivitiesViewController.h"
#import "CRTLoginViewModel.h"
#import "CRTSoundcloudActivitiesViewModel.h"
#import "CRTSoundcloudClient.h"
#import "CRTSoundcloudActivity.h"
#import "CRTSoundcloudTrack.h"
#import "CRTPageLoadingView.h"


@interface CRTActivitiesViewController ()

@property (nonatomic, strong, readonly) CRTSoundcloudActivitiesViewModel *viewModel;
@property (nonatomic, strong) CRTPageLoadingView *pageLoadingView;

@end


@implementation CRTActivitiesViewController

- (instancetype)initWithAPIClient:(CRTSoundcloudClient *)client
{
    NSCParameterAssert(client);

    self = [super initWithStyle:UITableViewStylePlain];

    if (self != nil) {
        self.title = @"Soundcloud";

        _viewModel = [[CRTSoundcloudActivitiesViewModel alloc] initWithAPIClient:client
                                                                        pageSize:10
                                                               minInvisibleItems:5];

        [self rac_liftSelector:@selector(pageLoadedWithActivities:) withSignals:_viewModel.pages, nil];

        // will complete when view is on screen and ready to go
        RACSignal *firstAppearance = [[[self rac_signalForSelector:@selector(viewDidAppear:)] take:1] ignoreValues];

        RACSignal *loginViewModel = [firstAppearance concat:[RACObserve(_viewModel, loginViewModel) ignore:nil]];

        [self rac_liftSelector:@selector(loginRequested:) withSignals:loginViewModel, nil];

        RACSignal *loggedIn = [[RACObserve(_viewModel, loginViewModel) distinctUntilChanged] map:^id(id value) {
            return @(value == nil);
        }];

        [_viewModel.loadNextPage rac_liftSelector:@selector(execute:) withSignals:[loggedIn ignore:@NO], nil];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pageLoadingView = [[CRTPageLoadingView alloc] init];
    self.tableView.tableFooterView = self.pageLoadingView;

    RACSignal *showLoadingView = [[[RACSignal combineLatest:@[
            self.viewModel.loadNextPage.executing,
            RACObserve(self.viewModel, lastPageLoadingFailed),
    ]] or] distinctUntilChanged];

    RACSignal *pageLoadingViewHeight =
        [showLoadingView map:^(NSNumber *flag) {
            if (flag.boolValue) {
                return @50;
            }
            else {
                return @0;
            }
        }];

    [self rac_liftSelector:@selector(updatePageLoadingViewHeight:) withSignals:pageLoadingViewHeight, nil];

    RAC(self.pageLoadingView, animating) = self.viewModel.loadNextPage.executing;


    self.tableView.rowHeight = 100;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    RACSignal *visibleCellChanges = [[RACSignal merge:@[
            [self rac_signalForSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)],
            [self rac_signalForSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]
    ]] mapReplace:[RACUnit defaultUnit]];

    self.tableView.delegate = nil;
    self.tableView.delegate = self;

    RACSignal *visibleRange = [[[visibleCellChanges mapReplace:self.tableView] map:^NSValue *(UITableView *tableView) {

        NSArray *visibleIndexPaths = [tableView.indexPathsForVisibleRows sortedArrayUsingSelector:@selector(compare:)];

        NSRange range;
        range.location = (NSUInteger) [visibleIndexPaths.firstObject row];
        range.length = (NSUInteger) [visibleIndexPaths.lastObject row] - range.location;

        return [NSValue valueWithRange:range];
    }] distinctUntilChanged];

    [self.viewModel rac_liftSelector:@selector(updateVisibleRange:) withSignals:visibleRange, nil];
}

- (void)loginRequested:(CRTLoginViewModel *)loginViewModel
{
    NSCParameterAssert(loginViewModel != nil);

    [loginViewModel.startLogin execute:nil];
}

- (void)pageLoadedWithActivities:(NSArray *)activities
{
    if (activities.count == self.viewModel.numberOfActivities) { // first page
        [self.tableView reloadData];
    }
    else {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:activities.count];

        NSUInteger baseIndex = self.viewModel.numberOfActivities - activities.count;

        for (NSUInteger index = baseIndex; index < self.viewModel.numberOfActivities; index++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [indexPaths addObject:indexPath];
        }

        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)updatePageLoadingViewHeight:(CGFloat)newHeight
{
    self.pageLoadingView.frame = CGRectMake(0, 0, 0, newHeight);

    self.tableView.tableFooterView = nil;
    self.tableView.tableFooterView = self.pageLoadingView;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CRTSoundcloudActivity *activity = [self.viewModel activityAtIndex:indexPath.row];

    if (activity.activityType == CRTSoundcloudTrackActivity) {
        CRTSoundcloudTrack *track = (CRTSoundcloudTrack *) activity.origin;
        NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"soundcloud:sounds:%llu", track.identifier]];
        UIApplication *application = [UIApplication sharedApplication];
        if ([application canOpenURL:appURL]) {
            [application openURL:appURL];
        }
        else {
            if (![application openURL:track.permalinkURL]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Cannot open this track :("
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];

                [alert show];
            }
        }
    }
    else {
        NSLog(@"Trying to open unsupported activity type");
    }

    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.numberOfActivities;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    CRTSoundcloudActivity *activity = [self.viewModel activityAtIndex:indexPath.row];

    if (activity.activityType == CRTSoundcloudTrackActivity) {
        CRTSoundcloudTrack *track = (CRTSoundcloudTrack *) activity.origin;

        cell.textLabel.text = track.title;
    }
    else {
        cell.textLabel.text = @"Unsupported activity";
    }

    return cell;
}

@end
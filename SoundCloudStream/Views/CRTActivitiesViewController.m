//
//  CRTActivitiesViewController.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 14.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <ReactiveCocoa/UIRefreshControl+RACCommandSupport.h>

#import "CRTActivitiesViewController.h"
#import "CRTLoginViewController.h"
#import "CRTLoginViewModel.h"
#import "CRTActivitiesViewModel.h"
#import "CRTSoundcloudActivity.h"
#import "CRTSoundcloudTrack.h"
#import "CRTPageLoadingView.h"
#import "CRTTrackCell.h"
#import "CRTErrorPresenter.h"


static NSArray *IndexPathsWithFromIndex(NSUInteger baseIndex, NSUInteger count, NSInteger section)
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:count];

    for (NSUInteger index = 0; index < count; index++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:baseIndex + index inSection:section]];
    }

    return indexPaths;
}



@interface CRTActivitiesViewController ()

@property (nonatomic, strong, readonly) CRTActivitiesViewModel *viewModel;
@property (nonatomic, strong) CRTPageLoadingView *pageLoadingView;

@property (nonatomic, strong, readonly) CRTErrorPresenter *errorPresenter;

@property (nonatomic, copy) NSString *activityCellReuseIdentifier;

@end


@implementation CRTActivitiesViewController

- (instancetype)initWithViewModel:(CRTActivitiesViewModel *)viewModel
                   errorPresenter:(CRTErrorPresenter *)errorPresenter
{
    NSCParameterAssert(viewModel != nil);
    NSCParameterAssert(errorPresenter != nil);

    self = [super initWithStyle:UITableViewStylePlain];

    if (self != nil) {
        self.title = @"SoundCloud";

        _viewModel = viewModel;
        _errorPresenter = errorPresenter;

        [self rac_liftSelector:@selector(pageDidLoadWithActivities:) withSignals:_viewModel.pages, nil];
        [self rac_liftSelector:@selector(freshActivitiesDidLoad:) withSignals:_viewModel.freshBatches, nil];

        // will complete when view is on screen and ready to go
        RACSignal *firstAppearance = [[[self rac_signalForSelector:@selector(viewDidAppear:)] take:1] ignoreValues];

        RACSignal *loginViewModel = [firstAppearance concat:_viewModel.authenticationRequests];

        [self rac_liftSelector:@selector(loginRequested:) withSignals:loginViewModel, nil];

        RACSignal *loggedOut = [RACObserve(_viewModel.loginViewModel, hasCredential) ignore:@YES];

        // it's like simple finite state machine:
        // (idle) -> (logged in) -> (logged out) -> (idle) -> ...
        RACSignal *pageLoadBecomesEnabled = [[[[_viewModel.loadNextPage.enabled ignore:@NO] // wait until page loading enabled
                                               take:1] // only take first value
                                               concat:[[loggedOut take:1] ignoreValues]] // do not complete signal until logout
                                               repeat]; // resubscribe to signal AFTER logout

        [_viewModel.loadNextPage rac_liftSelector:@selector(execute:)
                                      withSignals:pageLoadBecomesEnabled, nil];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([CRTTrackCell class]) bundle:nil];
    UITableViewCell *testCell = [cellNib instantiateWithOwner:nil options:nil].firstObject;
    self.activityCellReuseIdentifier = testCell.reuseIdentifier;
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.activityCellReuseIdentifier];

    self.tableView.rowHeight = CGRectGetHeight(testCell.frame);
    self.tableView.backgroundColor = testCell.backgroundColor;

    self.tableView.separatorInset = UIEdgeInsetsZero;

    @weakify(self);
    [self.viewModel.reloads subscribeNext:^(id _) {
        @strongify(self);
        [self.tableView reloadData];
    }];

    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", @"Logout button title")
                                                         style:UIBarButtonItemStylePlain
                                                        target:self.viewModel.loginViewModel
                                                        action:@selector(doLogout)];

    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Login", @"Login button title")
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(triggerLogin)];

    RAC(self.navigationItem, rightBarButtonItem) = [RACSignal if:RACObserve(self.viewModel.loginViewModel, hasCredential)
                                                    then:[RACSignal return:logoutButton]
                                                    else:[RACSignal return:loginButton]];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.rac_command = self.viewModel.refresh;

    self.pageLoadingView = [[CRTPageLoadingView alloc] init];
    [self.pageLoadingView.button setTitle:NSLocalizedString(@"Try again", @"Retry button title") forState:UIControlStateNormal];
    self.pageLoadingView.button.rac_command = self.viewModel.loadNextPage;
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
    RAC(self.pageLoadingView, displayButton) = [[RACSignal combineLatest:@[
            RACObserve(self.viewModel, lastPageLoadingFailed),
            [self.viewModel.loadNextPage.executing not]
    ]] and];

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

    [self.errorPresenter rac_liftSelector:@selector(presentError:) withSignals:self.viewModel.errors, nil];
}

- (void)triggerLogin
{
    [self loginRequested:self.viewModel.loginViewModel];
}

#pragma mark - View model signal handling

- (void)loginRequested:(CRTLoginViewModel *)loginViewModel
{
    NSCParameterAssert(loginViewModel != nil);

    CRTLoginViewController *controller = [[CRTLoginViewController alloc] initWithViewModel:loginViewModel
                                                                            errorPresenter:self.errorPresenter];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;

    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)pageDidLoadWithActivities:(NSArray *)activities
{
    if (activities.count == 0) {
        return;
    }

    if (activities.count == self.viewModel.numberOfActivities) { // first page
        [self.tableView reloadData];
    }
    else {
        NSUInteger baseIndex = self.viewModel.numberOfActivities - activities.count;
        NSArray *indexPaths = IndexPathsWithFromIndex(baseIndex, activities.count, 0);

        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)freshActivitiesDidLoad:(NSArray *)activities
{
    NSCAssert(self.viewModel.numberOfActivities > 0, @"Refresh should never occurr while activity list is empty");

    if (activities.count == 0) {
        return;
    }

    CGFloat futureContentOffsetY = self.tableView.contentOffset.y + activities.count * self.tableView.rowHeight;

    [self.tableView reloadData];

    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, futureContentOffsetY) animated:NO];
}

#pragma mark - Page loading view show/hide

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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title")
                                                                message:NSLocalizedString(@"Cannot open this track :(", @"Track opening error text")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
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
    CRTTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:self.activityCellReuseIdentifier forIndexPath:indexPath];

    CRTSoundcloudActivity *activity = [self.viewModel activityAtIndex:indexPath.row];

    if (activity.activityType == CRTSoundcloudTrackActivity) {
        CRTSoundcloudTrack *track = (CRTSoundcloudTrack *) activity.origin;

        [cell setTrackTitle:track.title];

        RACSignal *waveformImage = [[self.viewModel waveformImageForActivity:activity] takeUntil:cell.rac_prepareForReuseSignal];

        [cell rac_liftSelector:@selector(setWaveformImage:) withSignals:waveformImage, nil];
    }
    else {
        cell.textLabel.text = NSLocalizedString(@"Unsupported activity", @"Unsupported activity cell text");
    }

    cell.inUse = YES;

    return cell;
}

@end

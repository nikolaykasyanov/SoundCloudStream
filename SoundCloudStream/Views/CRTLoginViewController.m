//
//  CRTLoginViewController.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 16.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTLoginViewController.h"
#import "CRTLoginViewModel.h"
#import "CRTErrorPresenter.h"


@interface CRTLoginViewController ()

@property (nonatomic, strong) UIButton *connectButton;
@property (nonatomic, strong, readonly) CRTLoginViewModel *viewModel;

@property (nonatomic, strong, readonly) CRTErrorPresenter *errorPresenter;

@end


@implementation CRTLoginViewController

- (instancetype)initWithViewModel:(CRTLoginViewModel *)viewModel errorPresenter:(CRTErrorPresenter *)errorPresenter
{
    NSCParameterAssert(viewModel != nil);
    NSCParameterAssert(errorPresenter != nil);

    self = [super init];

    if (self != nil) {
        _viewModel = viewModel;
        _errorPresenter = errorPresenter;

        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = NSLocalizedString(@"Connect", @"Connect button title");
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];

    [self.viewModel.loading subscribeNext:^(NSNumber *flag) {
        if (flag.boolValue) {
            [activityIndicator startAnimating];
        }
        else {
            [activityIndicator stopAnimating];
        }
    }];

    self.view.backgroundColor = [UIColor whiteColor];

	// Do any additional setup after loading the view.

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(dismissSelf)];

    self.navigationItem.leftBarButtonItem = cancelItem;

    self.connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.connectButton setTitle:NSLocalizedString(@"Connect with SoundCloud", @"Connect button title")
                        forState:UIControlStateNormal];
    self.connectButton.rac_command = self.viewModel.startLogin;

    [self.view addSubview:self.connectButton];

    [[RACObserve(self.viewModel, hasCredential) ignore:@NO] subscribeNext:^(id _) {
        [self dismissSelf];
    }];

    [self.errorPresenter rac_liftSelector:@selector(presentError:) withSignals:self.viewModel.errors, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewWillLayoutSubviews];

    self.connectButton.bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50);
    self.connectButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

@end

//
//  CRTLoginViewController.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 16.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTLoginViewController.h"
#import "CRTLoginViewModel.h"


@interface CRTLoginViewController ()

@property (nonatomic, strong) UIButton *connectButton;
@property (nonatomic, strong, readonly) CRTLoginViewModel *viewModel;

@end


@implementation CRTLoginViewController

- (instancetype)initWithViewModel:(CRTLoginViewModel *)viewModel
{
    NSCParameterAssert(viewModel != nil);

    self = [super init];

    if (self != nil) {
        _viewModel = viewModel;

        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = @"Connect";
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(dismissSelf)];

    self.navigationItem.leftBarButtonItem = cancelItem;

    self.connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.connectButton setTitle:@"Connect with SoundCloud" forState:UIControlStateNormal];
    self.connectButton.rac_command = self.viewModel.startLogin;

    [self.view addSubview:self.connectButton];

    [[RACObserve(self.viewModel, hasCredential) ignore:@NO] subscribeNext:^(id _) {
        [self dismissSelf];
    }];
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

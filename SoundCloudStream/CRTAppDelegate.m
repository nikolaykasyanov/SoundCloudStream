//
//  CRTAppDelegate.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 07.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTAppDelegate.h"

#import "CRTSoundcloudClient.h"
#import "CRTActivitiesViewController.h"
#import "CRTLoginViewModel.h"
#import "CRTSoundcloudActivitiesViewModel.h"
#import "CRTKeychainCredentialStorage.h"
#import "CRTTrackCell.h"
#import "CRTErrorPresenter.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>


#ifdef DEBUG
/// Tests if .xctest bundle is loaded, so returns YES if the app is running with XCTest framework.
static inline BOOL IsUnitTesting() __attribute__((const));
static inline BOOL IsUnitTesting()
{
    NSDictionary *environment = [NSProcessInfo processInfo].environment;
    NSString *injectBundlePath = environment[@"XCInjectBundle"];
    return [injectBundlePath.pathExtension isEqualToString:@"xctest"];
}
#endif


@interface CRTAppDelegate ()

@property (nonatomic, strong) CRTSoundcloudClient *client;

@end


@implementation CRTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    if (IsUnitTesting()) {
        return YES;
    }
#endif

    [self setupAppearance];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    NSURL *endpointURL = [NSURL URLWithString:CRTSoundcloudEndpointURLString];

    self.client = [CRTSoundcloudClient managerWithBaseURL:endpointURL
                                                 clientID:CRTSoundcloudClientID
                                                   secret:CRTSoundcloudSecret];


    id <CRTCredentialStorage> credentialStorage = [[CRTKeychainCredentialStorage alloc] init];
    CRTLoginViewModel *loginViewModel = [[CRTLoginViewModel alloc] initWithClient:self.client credentialStorage:credentialStorage];

    CRTSoundcloudActivitiesViewModel *activitiesViewModel = [[CRTSoundcloudActivitiesViewModel alloc] initWithAPIClient:self.client
                                                                                                         loginViewModel:loginViewModel
                                                                                                               pageSize:10
                                                                                                      minInvisibleItems:5];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CRTErrorPresenter *errorPresenter = [[CRTErrorPresenter alloc] initWithApplicationWindow:self.window];

    CRTActivitiesViewController *viewController = [[CRTActivitiesViewController alloc] initWithViewModel:activitiesViewModel
                                                                                          errorPresenter:errorPresenter];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];

    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL canHandle = [url.scheme isEqualToString:CRTSoundcloudURLScheme];

    if (!canHandle) {
        return NO;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:CRTOpenURLNotification
                                                        object:nil
                                                      userInfo:@{CRTOpenURLNotificationURLKey: url}];

    return YES;
}

- (void)setupAppearance
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:232/255.0 green:75/255.0 blue:37/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont boldSystemFontOfSize:20],
                                                           }];

    NSDictionary *barItemsTitleAttributes = @{
                                              NSForegroundColorAttributeName : [UIColor whiteColor],
                                              };

    [[UIBarButtonItem appearance] setTitleTextAttributes:barItemsTitleAttributes
                                                forState:UIControlStateNormal];

    [[CRTTrackCell appearance] setWaveformBackgroundColor:[UIColor colorWithRed:58 /255.0
                                                                                    green:165/255.0
                                                                                     blue:226/255.0
                                                                                    alpha:1.0]];
}

@end

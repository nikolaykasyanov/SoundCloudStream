//
//  CRTAppDelegate.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 07.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTAppDelegate.h"
#import <GROAuth2SessionManager/GROAuth2SessionManager.h>


#import "CRTLoginViewModel.h"


@interface CRTAppDelegate ()

@property (nonatomic, strong) GROAuth2SessionManager *client;
@property (nonatomic, strong) CRTLoginViewModel *loginViewModel;

@end


@implementation CRTAppDelegate {
    CRTLoginViewModel *_loginViewModel;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    NSURL *endpointURL = [NSURL URLWithString:CRTSoundcloudEndpointURLString];

    self.client = [GROAuth2SessionManager managerWithBaseURL:endpointURL
                                                    clientID:CRTSoundcloudClientID
                                                      secret:CRTSoundcloudSecret];

    self.loginViewModel = [[CRTLoginViewModel alloc] initWithClient:self.client];

    [RACObserve(self.loginViewModel, authToken) subscribeNext:^(NSString *authToken) {
        NSLog(@"OAuth2 token received: %@", authToken);
    }];

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self.loginViewModel.startLogin execute:nil];
    });

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

@end

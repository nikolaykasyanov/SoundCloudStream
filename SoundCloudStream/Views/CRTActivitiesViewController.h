//
//  CRTActivitiesViewController.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 14.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRTSoundcloudClient;

@interface CRTActivitiesViewController : UITableViewController

- (instancetype)initWithAPIClient:(CRTSoundcloudClient *)client;

@end

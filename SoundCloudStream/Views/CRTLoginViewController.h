//
//  CRTLoginViewController.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 16.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CRTLoginViewModel;
@class CRTErrorPresenter;


@interface CRTLoginViewController : UIViewController

- (instancetype)initWithViewModel:(CRTLoginViewModel *)viewModel errorPresenter:(CRTErrorPresenter *)errorPresenter;

@end

//
//  CRTTrackCell.h
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 19.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRTTrackCell : UITableViewCell

- (void)setTrackTitle:(NSString *)trackTitle;
- (void)setWaveformImage:(UIImage *)waveformImage;

@property (nonatomic, strong) UIColor *waveformBackgroundColor UI_APPEARANCE_SELECTOR;

@end

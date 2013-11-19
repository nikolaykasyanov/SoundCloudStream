//
//  CRTSoundcloudTrackCell.m
//  SoundCloudStream
//
//  Created by Nikolay Kasyanov on 19.11.13.
//  Copyright (c) 2013 Nikolay Kasyanov. All rights reserved.
//

#import "CRTSoundcloudTrackCell.h"

@interface CRTSoundcloudTrackCell ()

@property (strong, nonatomic) IBOutlet UIImageView *waveformView;
@property (strong, nonatomic) IBOutlet UILabel *trackTitleLabel;

@end

@implementation CRTSoundcloudTrackCell

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.waveformView.image = nil;
    self.waveformView.backgroundColor = self.backgroundColor;
}

- (void)setTrackTitle:(NSString *)trackTitle
{
    self.trackTitleLabel.text = trackTitle;
}

- (void)setWaveformImage:(UIImage *)waveformImage
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    [self.waveformView.layer addAnimation:transition forKey:kCATransition];
    self.waveformView.backgroundColor = self.waveformBackgroundColor;
    self.waveformView.image = waveformImage;
}

@end

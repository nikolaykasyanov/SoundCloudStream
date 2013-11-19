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

@dynamic waveformBackgroundColor;

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.waveformView.image = nil;
}

- (void)setTrackTitle:(NSString *)trackTitle
{
    self.trackTitleLabel.text = trackTitle;
}

- (void)setWaveformImage:(UIImage *)waveformImage
{
    self.waveformView.image = waveformImage;
}

- (void)setWaveformBackgroundColor:(UIColor *)waveformBackgroundColor
{
    self.waveformView.backgroundColor = waveformBackgroundColor;
}

- (UIColor *)waveformBackgroundColor
{
    return self.waveformView.backgroundColor;
}

@end

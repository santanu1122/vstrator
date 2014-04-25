//
//  AVPlayer+Extensions.m
//  VstratorApp
//
//  Created by Mac on 24.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AVPlayer+Extensions.h"

@implementation AVPlayer (Extensions)

+ (void)mutePlayerItemAudio:(AVPlayerItem *)playerItem
{
    AVAsset *asset = [playerItem asset];
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    
    // Mute all the audio tracks
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams = AVMutableAudioMixInputParameters.audioMixInputParameters;
        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    
    [playerItem setAudioMix:audioZeroMix];
}

+ (id)dequeuePlayerWithURL:(NSURL *)url
{
    AVPlayer *player = [AVPlayer playerWithURL:url];
    if (player.error) {
        NSLog(@"Error with the player: %@", player.error);
    } else {
        [self.class mutePlayerItemAudio:player.currentItem];
    }
    return player;
}

@end

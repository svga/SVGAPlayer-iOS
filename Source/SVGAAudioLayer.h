//
//  SVGAAudioLayer.h
//  SVGAPlayer
//
//  Created by PonyCui on 2018/10/18.
//  Copyright © 2018年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class SVGAAudioEntity, SVGAVideoEntity;

@interface SVGAAudioLayer : NSObject

@property (nonatomic, readonly) AVAudioPlayer *audioPlayer;
@property (nonatomic, readonly) SVGAAudioEntity *audioItem;
@property (nonatomic, assign) BOOL audioPlaying;


- (instancetype)initWithAudioItem:(SVGAAudioEntity *)audioItem videoItem:(SVGAVideoEntity *)videoItem;

@end

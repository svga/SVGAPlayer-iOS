//
//  SVGAContentLayer.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/22.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVGABitmapLayer, SVGAVectorLayer, SVGAVideoSpriteFrameEntity;

@interface SVGAContentLayer : CALayer

@property (nonatomic, strong) SVGABitmapLayer *bitmapLayer;
@property (nonatomic, strong) SVGAVectorLayer *vectorLayer;

- (instancetype)initWithFrames:(NSArray<SVGAVideoSpriteFrameEntity *> *)frames;

- (void)stepToFrame:(NSInteger)frame;

@end

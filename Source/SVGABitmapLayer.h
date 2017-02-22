//
//  SVGABitmapLayer.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/20.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVGAVideoSpriteFrameEntity;

@interface SVGABitmapLayer : CALayer

- (instancetype)initWithFrames:(NSArray<SVGAVideoSpriteFrameEntity *> *)frames;

- (void)stepToFrame:(NSInteger)frame;

@end

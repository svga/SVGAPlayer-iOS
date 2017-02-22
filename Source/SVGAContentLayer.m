//
//  SVGAContentLayer.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/22.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "SVGAContentLayer.h"
#import "SVGABitmapLayer.h"
#import "SVGAVectorLayer.h"
#import "SVGAVideoSpriteFrameEntity.h"

@interface SVGAContentLayer ()

@property (nonatomic, strong) NSArray<SVGAVideoSpriteFrameEntity *> *frames;

@end

@implementation SVGAContentLayer

- (instancetype)initWithFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.masksToBounds = NO;
        _frames = frames;
        [self stepToFrame:0];
    }
    return self;
}

- (void)stepToFrame:(NSInteger)frame {
    if (frame < self.frames.count) {
        SVGAVideoSpriteFrameEntity *frameItem = self.frames[frame];
        if (frameItem.alpha > 0.0) {
            self.hidden = NO;
            self.opacity = frameItem.alpha;
            CGFloat nx = frameItem.nx;
            CGFloat ny = frameItem.ny;
            self.position = CGPointMake(0, 0);
            self.transform = CATransform3DIdentity;
            self.frame = frameItem.layout;
            self.transform = CATransform3DMakeAffineTransform(frameItem.transform);
            CGFloat offsetX = self.frame.origin.x - nx;
            CGFloat offsetY = self.frame.origin.y - ny;
            self.position = CGPointMake(self.position.x - offsetX, self.position.y - offsetY);
            self.mask = frameItem.maskLayer;
            [self.bitmapLayer stepToFrame:frame];
            [self.vectorLayer stepToFrame:frame];
        }
        else {
            self.hidden = YES;
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.bitmapLayer.frame = self.bounds;
    self.vectorLayer.frame = self.bounds;
    for (CALayer *sublayer in self.sublayers) {
        if ([sublayer isKindOfClass:[CATextLayer class]]) {
            CGRect frame = sublayer.frame;
            frame.origin.x = (self.frame.size.width - sublayer.frame.size.width) / 2.0;
            frame.origin.y = (self.frame.size.height - sublayer.frame.size.height) / 2.0;
            sublayer.frame = frame;
        }
    }
}

- (void)setBitmapLayer:(SVGABitmapLayer *)bitmapLayer {
    [_bitmapLayer removeFromSuperlayer];
    _bitmapLayer = bitmapLayer;
    [self addSublayer:bitmapLayer];
}

- (void)setVectorLayer:(SVGAVectorLayer *)vectorLayer {
    [_vectorLayer removeFromSuperlayer];
    _vectorLayer = vectorLayer;
    [self addSublayer:vectorLayer];
}

@end

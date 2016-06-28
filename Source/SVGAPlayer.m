//
//  SVGAPlayer.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGAPlayer.h"
#import "SVGAVideoEntity.h"

@interface SVGAPlayer () {
    int _loopCount;
}

@property (nonatomic, strong) CALayer *drawLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) int currentFrame;

@end

@implementation SVGAPlayer

- (void)startAnimation {
    [self stopAnimation:NO];
    _loopCount = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(next)];
    self.displayLink.frameInterval = 60 / self.videoItem.FPS;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopAnimation {
    [self stopAnimation:self.clearsAfterStop];
}

- (void)stopAnimation:(BOOL)clear {
    if (![self.displayLink isPaused]) {
        [self.displayLink setPaused:YES];
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    if (clear) {
        [self clear];
    }
}

- (void)clear {
    [self.drawLayer removeFromSuperlayer];
}

- (void)draw {
    self.drawLayer = [[CALayer alloc] init];
    self.drawLayer.frame = CGRectMake(0, 0, self.videoItem.videoSize.width, self.videoItem.videoSize.height);
    self.drawLayer.masksToBounds = true;
    [self.videoItem.sprites enumerateObjectsUsingBlock:^(SVGAVideoSpriteEntity * _Nonnull sprite, NSUInteger idx, BOOL * _Nonnull stop) {
        CALayer *spriteLayer = [[CALayer alloc] init];
        spriteLayer.contentsGravity = kCAGravityResizeAspect;
        spriteLayer.contents = (__bridge id _Nullable)([self.videoItem.images[sprite.imageKey] CGImage]);
        [spriteLayer setShouldRasterize:YES];
        [spriteLayer setRasterizationScale:[[UIScreen mainScreen] scale]];
        [self.drawLayer addSublayer:spriteLayer];
    }];
    [self.layer addSublayer:self.drawLayer];
    self.currentFrame = 0;
    [self update];
    [self resize];
}

- (void)resize {
    CGFloat ratio = self.frame.size.width / self.videoItem.videoSize.width;
    CGPoint offset = CGPointMake((1.0 - ratio) / 2.0 * self.videoItem.videoSize.width, (1 - ratio) / 2.0 * self.videoItem.videoSize.height);
    self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(ratio, 0, 0, ratio, -offset.x, -offset.y));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resize];
}

- (void)update {
    [CATransaction setDisableActions:YES];
    int currentFrame = self.currentFrame;
    int idx = 0;
    NSUInteger spritesCount = self.videoItem.sprites.count;
    for (CALayer *layer in self.drawLayer.sublayers) {
        if (idx < spritesCount) {
            if (currentFrame < self.videoItem.sprites[idx].frames.count) {
                SVGAVideoSpriteFrameEntity *frameItem = self.videoItem.sprites[idx].frames[currentFrame];
                if (frameItem.alpha > 0.0) {
                    layer.hidden = NO;
                    layer.opacity = frameItem.alpha;
                    CGFloat nx = frameItem.nx;
                    CGFloat ny = frameItem.ny;
                    layer.position = CGPointMake(0, 0);
                    layer.transform = CATransform3DIdentity;
                    layer.frame = frameItem.layout;
                    layer.transform = CATransform3DMakeAffineTransform(frameItem.transform);
                    CGFloat offsetX = layer.frame.origin.x - nx;
                    CGFloat offsetY = layer.frame.origin.y - ny;
                    layer.position = CGPointMake(layer.position.x - offsetX, layer.position.y - offsetY);
                }
                else {
                    layer.hidden = YES;
                }
            }
        }
        idx++;
    }
    [CATransaction setDisableActions:NO];
}

- (void)next {
    self.currentFrame++;
    if (self.currentFrame >= self.videoItem.frames) {
        self.currentFrame = 0;
        _loopCount++;
        if (self.loops > 0 && _loopCount >= self.loops) {
            [self stopAnimation];
            id delegate = self.delegate;
            if (delegate != nil && [delegate respondsToSelector:@selector(svgaPlayerDidFinishedAnimation:)]) {
                [delegate svgaPlayerDidFinishedAnimation:self];
            }
        }
    }
    [self update];
}

- (void)setVideoItem:(SVGAVideoEntity *)videoItem {
    _videoItem = videoItem;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self clear];
        [self draw];
    }];
}

@end

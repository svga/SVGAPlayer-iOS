//
//  SVGAPlayer.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGAPlayer.h"
#import "SVGAVideoEntity.h"

@interface SVGAPlayer ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) int currentFrame;

@end

@implementation SVGAPlayer

- (void)clear {
    [self.layer.sublayers performSelector:@selector(removeFromSuperlayer)];
}

- (void)draw {
    [self.videoItem.sprites enumerateObjectsUsingBlock:^(SVGAVideoSpriteEntity * _Nonnull sprite, NSUInteger idx, BOOL * _Nonnull stop) {
        CALayer *spriteLayer = [[CALayer alloc] init];
        spriteLayer.contentsGravity = kCAGravityResizeAspect;
        spriteLayer.contents = (__bridge id _Nullable)([self.videoItem.images[sprite.sKey] CGImage]);
        [self.layer addSublayer:spriteLayer];
    }];
    self.currentFrame = 0;
    [self update];
}

- (void)update {
    [CATransaction setDisableActions:YES];
    int currentFrame = self.currentFrame;
    [self.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        if (currentFrame < self.videoItem.sprites[idx].frames.count) {
            SVGAVideoSpriteFrameEntity *frameItem = self.videoItem.sprites[idx].frames[currentFrame];
            layer.opacity = frameItem.alpha;
            CGFloat llx = frameItem.transform.a * frameItem.layout.origin.x + frameItem.transform.c * frameItem.layout.origin.y + frameItem.transform.tx;
            CGFloat lrx = frameItem.transform.a * (frameItem.layout.origin.x + frameItem.layout.size.width) + frameItem.transform.c * frameItem.layout.origin.y + frameItem.transform.tx;
            CGFloat lbx = frameItem.transform.a * frameItem.layout.origin.x + frameItem.transform.c * (frameItem.layout.origin.y + frameItem.layout.size.height) + frameItem.transform.tx;
            CGFloat rbx = frameItem.transform.a * (frameItem.layout.origin.x + frameItem.layout.size.width) + frameItem.transform.c * (frameItem.layout.origin.y + frameItem.layout.size.height) + frameItem.transform.tx;
            CGFloat lly = frameItem.transform.b * frameItem.layout.origin.x + frameItem.transform.d * frameItem.layout.origin.y + frameItem.transform.ty;
            CGFloat lry = frameItem.transform.b * (frameItem.layout.origin.x + frameItem.layout.size.width) + frameItem.transform.d * frameItem.layout.origin.y + frameItem.transform.ty;
            CGFloat lby = frameItem.transform.b * frameItem.layout.origin.x + frameItem.transform.d * (frameItem.layout.origin.y + frameItem.layout.size.height) + frameItem.transform.ty;
            CGFloat rby = frameItem.transform.b * (frameItem.layout.origin.x + frameItem.layout.size.width) + frameItem.transform.d * (frameItem.layout.origin.y + frameItem.layout.size.height) + frameItem.transform.ty;
            CGFloat nx = MIN(MIN(lbx,  rbx), MIN(llx, lrx));
            CGFloat ny = MIN(MIN(lby,  rby), MIN(lly, lry));
            layer.position = CGPointMake(0, 0);
            layer.transform = CATransform3DIdentity;
            layer.frame = frameItem.layout;
            layer.transform = CATransform3DMakeAffineTransform(frameItem.transform);
            CGFloat offsetX = layer.frame.origin.x - nx;
            CGFloat offsetY = layer.frame.origin.y - ny;
            layer.position = CGPointMake(layer.position.x - offsetX, layer.position.y - offsetY);
        }
    }];
    [CATransaction setDisableActions:NO];
}

- (void)next {
    self.currentFrame++;
    if (self.currentFrame >= [self.videoItem.sprites firstObject].frames.count) {
        self.currentFrame = 0;
    }
    [self update];
}

- (void)startAnimation {
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(next)];
    self.displayLink.frameInterval = 3;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopAnimation {
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)setVideoItem:(SVGAVideoEntity *)videoItem {
    _videoItem = videoItem;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self clear];
        [self draw];
    }];
}

@end

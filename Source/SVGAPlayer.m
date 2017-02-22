//
//  SVGAPlayer.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGAPlayer.h"
#import "SVGAVideoEntity.h"
#import "SVGAVideoSpriteEntity.h"
#import "SVGAVideoSpriteFrameEntity.h"
#import "SVGAContentLayer.h"
#import "SVGAVectorLayer.h"

@interface SVGAPlayer () {
    int _loopCount;
}

@property (nonatomic, strong) CALayer *drawLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSInteger currentFrame;
@property (nonatomic, copy) NSDictionary *dynamicObjects;
@property (nonatomic, copy) NSDictionary *dynamicLayers;
@property (nonatomic, copy) NSDictionary *dynamicTexts;

@end

@implementation SVGAPlayer

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) {
        [self stopAnimation:YES];
    }
}

- (void)startAnimation {
    [self stopAnimation:NO];
    _loopCount = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(next)];
    self.displayLink.frameInterval = 60 / self.videoItem.FPS;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)pauseAnimation {
    [self stopAnimation:NO];
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
    self.displayLink = nil;
}

- (void)clear {
    [self.drawLayer removeFromSuperlayer];
}

- (void)stepToFrame:(NSInteger)frame andPlay:(BOOL)andPlay {
    if (frame >= self.videoItem.frames) {
        return;
    }
    [self pauseAnimation];
    self.currentFrame = frame;
    [self update];
    if (andPlay) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(next)];
        self.displayLink.frameInterval = 60 / self.videoItem.FPS;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)stepToPercentage:(CGFloat)percentage andPlay:(BOOL)andPlay {
    NSInteger frame = (NSInteger)(self.videoItem.frames * percentage);
    if (frame >= self.videoItem.frames && frame > 0) {
        frame = self.videoItem.frames - 1;
    }
    [self stepToFrame:frame andPlay:andPlay];
}

- (void)draw {
    self.drawLayer = [[CALayer alloc] init];
    self.drawLayer.frame = CGRectMake(0, 0, self.videoItem.videoSize.width, self.videoItem.videoSize.height);
    self.drawLayer.masksToBounds = true;
    [self.videoItem.sprites enumerateObjectsUsingBlock:^(SVGAVideoSpriteEntity * _Nonnull sprite, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.drawLayer addSublayer:[sprite requestLayer]];
//        CALayer *spriteLayer = [[CALayer alloc] init];
//        spriteLayer.contentsGravity = kCAGravityResizeAspect;
//        if (sprite.imageKey != nil) {
//            if (self.dynamicLayers[sprite.imageKey] != nil) {
//                spriteLayer = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.dynamicLayers[sprite.imageKey]]];
//                spriteLayer.contentsGravity = kCAGravityResizeAspect;
//            }
//            if (self.dynamicObjects[sprite.imageKey] != nil) {
//                spriteLayer.contents = (__bridge id _Nullable)([self.dynamicObjects[sprite.imageKey] CGImage]);
//            }
//            else {
//                spriteLayer.contents = (__bridge id _Nullable)([self.videoItem.images[sprite.imageKey] CGImage]);
//            }
//            if (self.dynamicTexts[sprite.imageKey] != nil) {
//                NSAttributedString *text = self.dynamicTexts[sprite.imageKey];
//                CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
//                CATextLayer *textLayer = [CATextLayer layer];
//                [textLayer setString:self.dynamicTexts[sprite.imageKey]];
//                textLayer.frame = CGRectMake(0, 0, size.width, size.height);
//                [spriteLayer addSublayer:textLayer];
//            }
//            [self.drawLayer addSublayer:spriteLayer];
//        }
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
    NSInteger currentFrame = self.currentFrame;
    int idx = 0;
    NSUInteger spritesCount = self.videoItem.sprites.count;
    for (SVGAContentLayer *layer in self.drawLayer.sublayers) {
        if ([layer isKindOfClass:[SVGAContentLayer class]]) {
            [layer stepToFrame:currentFrame];
        }
//        if (idx < spritesCount) {
//            if (currentFrame < self.videoItem.sprites[idx].frames.count) {
//                SVGAVideoSpriteFrameEntity *frameItem = self.videoItem.sprites[idx].frames[currentFrame];
//                if (frameItem.alpha > 0.0) {
//                    layer.hidden = NO;
//                    layer.opacity = frameItem.alpha;
//                    CGFloat nx = frameItem.nx;
//                    CGFloat ny = frameItem.ny;
//                    layer.position = CGPointMake(0, 0);
//                    layer.transform = CATransform3DIdentity;
//                    layer.frame = frameItem.layout;
//                    layer.transform = CATransform3DMakeAffineTransform(frameItem.transform);
//                    CGFloat offsetX = layer.frame.origin.x - nx;
//                    CGFloat offsetY = layer.frame.origin.y - ny;
//                    layer.position = CGPointMake(layer.position.x - offsetX, layer.position.y - offsetY);
//                    layer.mask = frameItem.maskLayer;
//                    for (CALayer *sublayer in layer.sublayers) {
//                        if ([sublayer isKindOfClass:[CATextLayer class]]) {
//                            CGRect frame = sublayer.frame;
//                            frame.origin.x = (layer.frame.size.width - sublayer.frame.size.width) / 2.0;
//                            frame.origin.y = (layer.frame.size.height - sublayer.frame.size.height) / 2.0;
//                            sublayer.frame = frame;
//                        }
//                    }
//                    for (CALayer *sublayer in layer.sublayers) {
//                        if ([sublayer isKindOfClass:[SVGAVectorLayer class]]) {
//                            [sublayer removeFromSuperlayer];
//                        }
//                    }
//                    
//                }
//                else {
//                    layer.hidden = YES;
//                }
//            }
//        }
//        idx++;
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
    id delegate = self.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(svgaPlayerDidAnimatedToFrame:)]) {
        [delegate svgaPlayerDidAnimatedToFrame:self.currentFrame];
    }
    if (delegate != nil && [delegate respondsToSelector:@selector(svgaPlayerDidAnimatedToPercentage:)] && self.videoItem.frames > 0) {
        [delegate svgaPlayerDidAnimatedToPercentage:(CGFloat)(self.currentFrame + 1) / (CGFloat)self.videoItem.frames];
    }
}

- (void)setVideoItem:(SVGAVideoEntity *)videoItem {
    _videoItem = videoItem;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self clear];
        [self draw];
    }];
}

#pragma mark - Dynamic Object

- (void)setImage:(UIImage *)image forKey:(NSString *)aKey referenceLayer:(CALayer *)referenceLayer {
    if (image == nil) {
        return;
    }
    NSMutableDictionary *mutableDynamicObjects = [self.dynamicObjects mutableCopy];
    [mutableDynamicObjects setObject:image forKey:aKey];
    self.dynamicObjects = mutableDynamicObjects;
    if (referenceLayer != nil) {
        NSMutableDictionary *mutableDynamicLayers = [self.dynamicLayers mutableCopy];
        [mutableDynamicLayers setObject:referenceLayer forKey:aKey];
        self.dynamicLayers = mutableDynamicLayers;
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText forKey:(NSString *)aKey {
    if (attributedText == nil) {
        return;
    }
    NSMutableDictionary *mutableDynamicTexts = [self.dynamicTexts mutableCopy];
    [mutableDynamicTexts setObject:attributedText forKey:aKey];
    self.dynamicTexts = mutableDynamicTexts;
}

- (void)clearDynamicObjects {
    self.dynamicObjects = nil;
    self.dynamicLayers = nil;
}

- (NSDictionary *)dynamicObjects {
    if (_dynamicObjects == nil) {
        _dynamicObjects = @{};
    }
    return _dynamicObjects;
}

- (NSDictionary *)dynamicLayers {
    if (_dynamicLayers == nil) {
        _dynamicLayers = @{};
    }
    return _dynamicLayers;
}

- (NSDictionary *)dynamicTexts {
    if (_dynamicTexts == nil) {
        _dynamicTexts = @{};
    }
    return _dynamicTexts;
}

@end

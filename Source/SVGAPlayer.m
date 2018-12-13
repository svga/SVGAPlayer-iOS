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
#import "SVGABitmapLayer.h"
#import "SVGAVectorLayer.h"
#import "SVGAAudioLayer.h"
#import "SVGAAudioEntity.h"

@interface SVGAPlayer ()

@property (nonatomic, strong) CALayer *drawLayer;
@property (nonatomic, strong) NSArray<SVGAAudioLayer *> *audioLayers;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSInteger currentFrame;
@property (nonatomic, copy) NSDictionary<NSString *, UIImage *> *dynamicObjects;
@property (nonatomic, copy) NSDictionary<NSString *, NSAttributedString *> *dynamicTexts;
@property (nonatomic, copy) NSDictionary<NSString *, SVGAPlayerDynamicDrawingBlock> *dynamicDrawings;
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *dynamicHiddens;
@property (nonatomic, assign) int loopCount;
@property (nonatomic, assign) NSRange currentRange;
@property (nonatomic, assign) BOOL forwardAnimating;
@property (nonatomic, assign) BOOL reversing;

@end

@implementation SVGAPlayer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeTop;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) {
        [self stopAnimation:YES];
    }
}

- (void)startAnimation {
    [self stopAnimation:NO];
    self.loopCount = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(next)];
    self.displayLink.frameInterval = 60 / self.videoItem.FPS;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.forwardAnimating = !self.reversing;
}

- (void)startAnimationWithRange:(NSRange)range reverse:(BOOL)reverse {
    self.currentRange = range;
    self.reversing = reverse;
    if (reverse) {
        self.currentFrame = MIN(self.videoItem.frames - 1, range.location + range.length - 1);
    }
    else {
        self.currentFrame = MAX(0, range.location);
    }
    [self startAnimation];
}

- (void)pauseAnimation {
    [self stopAnimation:NO];
}

- (void)stopAnimation {
    [self stopAnimation:self.clearsAfterStop];
}

- (void)stopAnimation:(BOOL)clear {
    self.forwardAnimating = NO;
    if (self.displayLink != nil) {
        [self.displayLink invalidate];
    }
    if (clear) {
        [self clear];
    }
    [self clearAudios];
    self.displayLink = nil;
}

- (void)clear {
    [self.drawLayer removeFromSuperlayer];
}

- (void)clearAudios {
    for (SVGAAudioLayer *layer in self.audioLayers) {
        [layer.audioPlayer stop];
    }
}

- (void)stepToFrame:(NSInteger)frame andPlay:(BOOL)andPlay {
    if (frame >= self.videoItem.frames || frame < 0) {
        return;
    }
    [self pauseAnimation];
    self.currentFrame = frame;
    [self update];
    if (andPlay) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(next)];
        self.displayLink.frameInterval = 60 / self.videoItem.FPS;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
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
        UIImage *bitmap;
        if (sprite.imageKey != nil) {
            if (self.dynamicObjects[sprite.imageKey] != nil) {
                bitmap = self.dynamicObjects[sprite.imageKey];
            }
            else {
                bitmap = self.videoItem.images[sprite.imageKey];
            }
        }
        SVGAContentLayer *contentLayer = [sprite requestLayerWithBitmap:bitmap];
        contentLayer.imageKey = sprite.imageKey;
        [self.drawLayer addSublayer:contentLayer];
        if (sprite.imageKey != nil) {
            if (self.dynamicTexts[sprite.imageKey] != nil) {
                NSAttributedString *text = self.dynamicTexts[sprite.imageKey];
                CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
                CATextLayer *textLayer = [CATextLayer layer];
                textLayer.contentsScale = [[UIScreen mainScreen] scale];
                [textLayer setString:self.dynamicTexts[sprite.imageKey]];
                textLayer.frame = CGRectMake(0, 0, size.width, size.height);
                [contentLayer addSublayer:textLayer];
                contentLayer.textLayer = textLayer;
            }
            if (self.dynamicHiddens[sprite.imageKey] != nil &&
                [self.dynamicHiddens[sprite.imageKey] boolValue] == YES) {
                contentLayer.dynamicHidden = YES;
            }
            if (self.dynamicDrawings[sprite.imageKey] != nil) {
                contentLayer.dynamicDrawingBlock = self.dynamicDrawings[sprite.imageKey];
            }
        }
    }];
    [self.layer addSublayer:self.drawLayer];
    NSMutableArray *audioLayers = [NSMutableArray array];
    [self.videoItem.audios enumerateObjectsUsingBlock:^(SVGAAudioEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SVGAAudioLayer *audioLayer = [[SVGAAudioLayer alloc] initWithAudioItem:obj videoItem:self.videoItem];
        [audioLayers addObject:audioLayer];
    }];
    self.audioLayers = audioLayers;
    [self update];
    [self resize];
}

- (void)resize {
    if (self.contentMode == UIViewContentModeScaleAspectFit) {
        CGFloat videoRatio = self.videoItem.videoSize.width / self.videoItem.videoSize.height;
        CGFloat layerRatio = self.bounds.size.width / self.bounds.size.height;
        if (videoRatio > layerRatio) {
            CGFloat ratio = self.bounds.size.width / self.videoItem.videoSize.width;
            CGPoint offset = CGPointMake(
                                         (1.0 - ratio) / 2.0 * self.videoItem.videoSize.width,
                                         (1.0 - ratio) / 2.0 * self.videoItem.videoSize.height
                                         - (self.bounds.size.height - self.videoItem.videoSize.height * ratio) / 2.0
                                         );
            self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(ratio, 0, 0, ratio, -offset.x, -offset.y));
        }
        else {
            CGFloat ratio = self.bounds.size.height / self.videoItem.videoSize.height;
            CGPoint offset = CGPointMake(
                                         (1.0 - ratio) / 2.0 * self.videoItem.videoSize.width - (self.bounds.size.width - self.videoItem.videoSize.width * ratio) / 2.0,
                                         (1.0 - ratio) / 2.0 * self.videoItem.videoSize.height);
            self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(ratio, 0, 0, ratio, -offset.x, -offset.y));
        }
    }
    else if (self.contentMode == UIViewContentModeScaleAspectFill) {
        CGFloat videoRatio = self.videoItem.videoSize.width / self.videoItem.videoSize.height;
        CGFloat layerRatio = self.bounds.size.width / self.bounds.size.height;
        if (videoRatio < layerRatio) {
            CGFloat ratio = self.bounds.size.width / self.videoItem.videoSize.width;
            CGPoint offset = CGPointMake(
                                         (1.0 - ratio) / 2.0 * self.videoItem.videoSize.width,
                                         (1.0 - ratio) / 2.0 * self.videoItem.videoSize.height
                                         - (self.bounds.size.height - self.videoItem.videoSize.height * ratio) / 2.0
                                         );
            self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(ratio, 0, 0, ratio, -offset.x, -offset.y));
        }
        else {
            CGFloat ratio = self.bounds.size.height / self.videoItem.videoSize.height;
            CGPoint offset = CGPointMake(
                                         (1.0 - ratio) / 2.0 * self.videoItem.videoSize.width - (self.bounds.size.width - self.videoItem.videoSize.width * ratio) / 2.0,
                                         (1.0 - ratio) / 2.0 * self.videoItem.videoSize.height);
            self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(ratio, 0, 0, ratio, -offset.x, -offset.y));
        }
    }
    else if (self.contentMode == UIViewContentModeTop) {
        CGFloat scaleX = self.frame.size.width / self.videoItem.videoSize.width;
        CGPoint offset = CGPointMake((1.0 - scaleX) / 2.0 * self.videoItem.videoSize.width, (1 - scaleX) / 2.0 * self.videoItem.videoSize.height);
        self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(scaleX, 0, 0, scaleX, -offset.x, -offset.y));
    }
    else if (self.contentMode == UIViewContentModeBottom) {
        CGFloat scaleX = self.frame.size.width / self.videoItem.videoSize.width;
        CGPoint offset = CGPointMake(
                                     (1.0 - scaleX) / 2.0 * self.videoItem.videoSize.width,
                                     (1.0 - scaleX) / 2.0 * self.videoItem.videoSize.height);
        self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(scaleX, 0, 0, scaleX, -offset.x, -offset.y + self.frame.size.height - self.videoItem.videoSize.height * scaleX));
    }
    else if (self.contentMode == UIViewContentModeLeft) {
        CGFloat scaleY = self.frame.size.height / self.videoItem.videoSize.height;
        CGPoint offset = CGPointMake((1.0 - scaleY) / 2.0 * self.videoItem.videoSize.width, (1 - scaleY) / 2.0 * self.videoItem.videoSize.height);
        self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(scaleY, 0, 0, scaleY, -offset.x, -offset.y));
    }
    else if (self.contentMode == UIViewContentModeRight) {
        CGFloat scaleY = self.frame.size.height / self.videoItem.videoSize.height;
        CGPoint offset = CGPointMake(
                                     (1.0 - scaleY) / 2.0 * self.videoItem.videoSize.width,
                                     (1.0 - scaleY) / 2.0 * self.videoItem.videoSize.height);
        self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(scaleY, 0, 0, scaleY, -offset.x + self.frame.size.width - self.videoItem.videoSize.width * scaleY, -offset.y));
    }
    else {
        CGFloat scaleX = self.frame.size.width / self.videoItem.videoSize.width;
        CGFloat scaleY = self.frame.size.height / self.videoItem.videoSize.height;
        CGPoint offset = CGPointMake((1.0 - scaleX) / 2.0 * self.videoItem.videoSize.width, (1 - scaleY) / 2.0 * self.videoItem.videoSize.height);
        self.drawLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(scaleX, 0, 0, scaleY, -offset.x, -offset.y));
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resize];
}

- (void)update {
    [CATransaction setDisableActions:YES];
    for (SVGAContentLayer *layer in self.drawLayer.sublayers) {
        if ([layer isKindOfClass:[SVGAContentLayer class]]) {
            [layer stepToFrame:self.currentFrame];
        }
    }
    [CATransaction setDisableActions:NO];
    if (self.forwardAnimating && self.audioLayers.count > 0) {
        for (SVGAAudioLayer *layer in self.audioLayers) {
            if (layer.audioItem.startFrame == self.currentFrame) {
                [layer.audioPlayer setCurrentTime:(NSTimeInterval)(layer.audioItem.startTime / 1000)];
                [layer.audioPlayer play];
            }
            else if (layer.audioItem.endFrame <= self.currentFrame) {
                [layer.audioPlayer stop];
            }
        }
    }
}

- (void)next {
    if (self.reversing) {
        self.currentFrame--;
        if (self.currentFrame < (NSInteger)MAX(0, self.currentRange.location)) {
            self.currentFrame = MIN(self.videoItem.frames - 1, self.currentRange.location + self.currentRange.length - 1);
            self.loopCount++;
        }
    }
    else {
        self.currentFrame++;
        if (self.currentFrame >= MIN(self.videoItem.frames, self.currentRange.location + self.currentRange.length)) {
            self.currentFrame = MAX(0, self.currentRange.location);
            [self clearAudios];
            self.loopCount++;
        }
    }
    if (self.loops > 0 && self.loopCount >= self.loops) {
        [self stopAnimation];
        if (!self.clearsAfterStop && [self.fillMode isEqualToString:@"Backward"]) {
            [self stepToFrame:MAX(0, self.currentRange.location) andPlay:NO];
        }
        else if (!self.clearsAfterStop && [self.fillMode isEqualToString:@"Forward"]) {
            [self stepToFrame:MIN(self.videoItem.frames - 1, self.currentRange.location + self.currentRange.length - 1) andPlay:NO];
        }
        id delegate = self.delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(svgaPlayerDidFinishedAnimation:)]) {
            [delegate svgaPlayerDidFinishedAnimation:self];
        }
        return;
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
    _currentRange = NSMakeRange(0, videoItem.frames);
    _reversing = NO;
    _currentFrame = 0;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self clear];
        [self draw];
    }];
}

#pragma mark - Dynamic Object

- (void)setImage:(UIImage *)image forKey:(NSString *)aKey {
    if (image == nil) {
        return;
    }
    NSMutableDictionary *mutableDynamicObjects = [self.dynamicObjects mutableCopy];
    [mutableDynamicObjects setObject:image forKey:aKey];
    self.dynamicObjects = mutableDynamicObjects;
    if (self.drawLayer.sublayers.count > 0) {
        for (SVGAContentLayer *layer in self.drawLayer.sublayers) {
            if ([layer isKindOfClass:[SVGAContentLayer class]] && [layer.imageKey isEqualToString:aKey]) {
                layer.bitmapLayer.contents = (__bridge id _Nullable)([image CGImage]);
            }
        }
    }
}

- (void)setImageWithURL:(NSURL *)URL forKey:(NSString *)aKey {
    [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil && data != nil) {
            UIImage *image = [UIImage imageWithData:data];
            if (image != nil) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self setImage:image forKey:aKey];
                }];
            }
        }
    }] resume];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)aKey referenceLayer:(CALayer *)referenceLayer {
    [self setImage:image forKey:aKey];
}

- (void)setAttributedText:(NSAttributedString *)attributedText forKey:(NSString *)aKey {
    if (attributedText == nil) {
        return;
    }
    NSMutableDictionary *mutableDynamicTexts = [self.dynamicTexts mutableCopy];
    [mutableDynamicTexts setObject:attributedText forKey:aKey];
    self.dynamicTexts = mutableDynamicTexts;
    if (self.drawLayer.sublayers.count > 0) {
        CGSize size = [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
        CATextLayer *textLayer;
        for (SVGAContentLayer *layer in self.drawLayer.sublayers) {
            if ([layer isKindOfClass:[SVGAContentLayer class]] && [layer.imageKey isEqualToString:aKey]) {
                textLayer = layer.textLayer;
                if (textLayer == nil) {
                    textLayer = [CATextLayer layer];
                    [layer addSublayer:textLayer];
                    layer.textLayer = textLayer;
                }
            }
        }
        if (textLayer != nil) {
            textLayer.contentsScale = [[UIScreen mainScreen] scale];
            [textLayer setString:attributedText];
            textLayer.frame = CGRectMake(0, 0, size.width, size.height);
        }
    }
}

- (void)setDrawingBlock:(SVGAPlayerDynamicDrawingBlock)drawingBlock forKey:(NSString *)aKey {
    NSMutableDictionary *mutableDynamicDrawings = [self.dynamicDrawings mutableCopy];
    [mutableDynamicDrawings setObject:drawingBlock forKey:aKey];
    self.dynamicDrawings = mutableDynamicDrawings;
    if (self.drawLayer.sublayers.count > 0) {
        for (SVGAContentLayer *layer in self.drawLayer.sublayers) {
            if ([layer isKindOfClass:[SVGAContentLayer class]] &&
                [layer.imageKey isEqualToString:aKey]) {
                layer.dynamicDrawingBlock = drawingBlock;
            }
        }
    }
}

- (void)setHidden:(BOOL)hidden forKey:(NSString *)aKey {
    NSMutableDictionary *mutableDynamicHiddens = [self.dynamicHiddens mutableCopy];
    [mutableDynamicHiddens setObject:@(hidden) forKey:aKey];
    self.dynamicHiddens = mutableDynamicHiddens;
    if (self.drawLayer.sublayers.count > 0) {
        for (SVGAContentLayer *layer in self.drawLayer.sublayers) {
            if ([layer isKindOfClass:[SVGAContentLayer class]] &&
                [layer.imageKey isEqualToString:aKey]) {
                layer.dynamicHidden = hidden;
            }
        }
    }
}

- (void)clearDynamicObjects {
    self.dynamicObjects = nil;
    self.dynamicTexts = nil;
    self.dynamicHiddens = nil;
    self.dynamicDrawings = nil;
}

- (NSDictionary *)dynamicObjects {
    if (_dynamicObjects == nil) {
        _dynamicObjects = @{};
    }
    return _dynamicObjects;
}

- (NSDictionary *)dynamicTexts {
    if (_dynamicTexts == nil) {
        _dynamicTexts = @{};
    }
    return _dynamicTexts;
}

- (NSDictionary *)dynamicHiddens {
    if (_dynamicHiddens == nil) {
        _dynamicHiddens = @{};
    }
    return _dynamicHiddens;
}

- (NSDictionary<NSString *,SVGAPlayerDynamicDrawingBlock> *)dynamicDrawings {
    if (_dynamicDrawings == nil) {
        _dynamicDrawings = @{};
    }
    return _dynamicDrawings;
}

@end

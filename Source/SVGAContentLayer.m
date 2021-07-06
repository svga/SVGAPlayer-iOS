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
@property (nonatomic, assign) NSTextAlignment textLayerAlignment;

@end

@implementation SVGAContentLayer

- (instancetype)initWithFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.masksToBounds = NO;
        _frames = frames;
        _textLayerAlignment = NSTextAlignmentCenter;
        [self stepToFrame:0];
    }
    return self;
}

- (void)stepToFrame:(NSInteger)frame {
    if (self.dynamicHidden) {
        return;
    }
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
            if (frameItem.maskLayer != nil) {
                if ([frameItem.maskLayer isKindOfClass:[CAShapeLayer class]]) {
                    CAShapeLayer *cloneShapeLayer = [CAShapeLayer layer];
                    cloneShapeLayer.path = [(CAShapeLayer *)frameItem.maskLayer path];
                    cloneShapeLayer.fillColor = [(CAShapeLayer *)frameItem.maskLayer fillColor];
                    self.mask = cloneShapeLayer;
                }
            }
            else {
                self.mask = nil;
            }
            [self.bitmapLayer stepToFrame:frame];
            [self.vectorLayer stepToFrame:frame];
        }
        else {
            self.hidden = YES;
        }
        if (self.dynamicDrawingBlock) {
            self.dynamicDrawingBlock(self, frame);
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
            switch (self.textLayerAlignment) {
                case NSTextAlignmentLeft:
                    frame.origin.x = 0.0;
                    break;
                case NSTextAlignmentCenter:
                    frame.origin.x = (self.frame.size.width - sublayer.frame.size.width) / 2.0;
                    break;
                case NSTextAlignmentRight:
                    frame.origin.x = self.frame.size.width - sublayer.frame.size.width;
                    break;
                default:
                    frame.origin.x = (self.frame.size.width - sublayer.frame.size.width) / 2.0;
                    break;
            }
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

- (void)setDynamicHidden:(BOOL)dynamicHidden {
    _dynamicHidden = dynamicHidden;
    self.hidden = dynamicHidden;
}

- (void)resetTextLayerProperties:(NSAttributedString *)attributedString {
    NSDictionary *textAttrs = (id)[attributedString attributesAtIndex:0 effectiveRange:nil];
    NSParagraphStyle *paragraphStyle = textAttrs[NSParagraphStyleAttributeName];
    if (paragraphStyle == nil) {
        return;
    }
    if (paragraphStyle.lineBreakMode == NSLineBreakByTruncatingTail) {
        self.textLayer.truncationMode = kCATruncationEnd;
        [self.textLayer setWrapped:NO];
    }
    else if (paragraphStyle.lineBreakMode == NSLineBreakByTruncatingMiddle) {
        self.textLayer.truncationMode = kCATruncationMiddle;
        [self.textLayer setWrapped:NO];
    }
    else if (paragraphStyle.lineBreakMode == NSLineBreakByTruncatingHead) {
        self.textLayer.truncationMode = kCATruncationStart;
        [self.textLayer setWrapped:NO];
    }
    else {
        self.textLayer.truncationMode = kCATruncationNone;
        [self.textLayer setWrapped:YES];
    }
    if (paragraphStyle.alignment == NSTextAlignmentNatural) {
        self.textLayerAlignment = NSTextAlignmentCenter;
    }
    else {
        self.textLayerAlignment = paragraphStyle.alignment;
    }
}

@end

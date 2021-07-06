//
//  SVGAVectorLayer.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/20.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "SVGAVectorLayer.h"
#import "SVGABezierPath.h"
#import "SVGAVideoSpriteFrameEntity.h"
#import "Svga.pbobjc.h"

@interface SVGAVectorLayer ()

@property (nonatomic, strong) NSArray<SVGAVideoSpriteFrameEntity *> *frames;
@property (nonatomic, assign) NSInteger drawedFrame;
@property (nonatomic, strong) NSDictionary *keepFrameCache;

@end

@implementation SVGAVectorLayer

- (instancetype)initWithFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.masksToBounds = NO;
        _frames = frames;
        _keepFrameCache = [NSMutableDictionary dictionary];
        [self resetKeepFrameCache];
        [self stepToFrame:0];
    }
    return self;
}

- (void)resetKeepFrameCache {
    __block NSInteger lastKeep = 0;
    __block NSMutableDictionary *keepFrameCache = [NSMutableDictionary dictionary];
    [self.frames enumerateObjectsUsingBlock:^(SVGAVideoSpriteFrameEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self isKeepFrame:obj]) {
            lastKeep = idx;
        }
        else {
            [keepFrameCache setObject:@(lastKeep) forKey:@(idx)];
        }
    }];
    self.keepFrameCache = [keepFrameCache copy];
}

- (void)stepToFrame:(NSInteger)frame {
    if (frame < self.frames.count) {
        [self drawFrame:frame];
    }
}

- (BOOL)isKeepFrame:(SVGAVideoSpriteFrameEntity *)frameItem {
    if (frameItem.shapes.count == 0) {
        return NO;
    }
    else if ([frameItem.shapes.firstObject isKindOfClass:[NSDictionary class]]) {
        return [frameItem.shapes.firstObject[@"type"] isKindOfClass:[NSString class]] &&
        [frameItem.shapes.firstObject[@"type"] isEqualToString:@"keep"];
    }
    else if ([frameItem.shapes.firstObject isKindOfClass:[SVGAProtoShapeEntity class]]) {
        return [(SVGAProtoShapeEntity *)frameItem.shapes.firstObject type] == SVGAProtoShapeEntity_ShapeType_Keep;
    }
    else {
        return NO;
    }
}

- (NSInteger)requestKeepFrame:(NSInteger)frame {
    if ([self.keepFrameCache objectForKey:@(frame)] != nil) {
        return [[self.keepFrameCache objectForKey:@(frame)] integerValue];
    }
    return NSNotFound;
}

- (void)drawFrame:(NSInteger)frame {
    if (frame < self.frames.count) {
        SVGAVideoSpriteFrameEntity *frameItem = self.frames[frame];
        if ([self isKeepFrame:frameItem]) {
            if (self.drawedFrame == [self requestKeepFrame:frame]) {
                return;
            }
        }
        while(self.sublayers.count) [self.sublayers.firstObject removeFromSuperlayer];
        for (NSDictionary *shape in frameItem.shapes) {
            if ([shape isKindOfClass:[NSDictionary class]]) {
                if ([shape[@"type"] isKindOfClass:[NSString class]]) {
                    if ([shape[@"type"] isEqualToString:@"shape"]) {
                        [self addSublayer:[self createCurveLayer:shape]];
                    }
                    else if ([shape[@"type"] isEqualToString:@"ellipse"]) {
                        [self addSublayer:[self createEllipseLayer:shape]];
                    }
                    else if ([shape[@"type"] isEqualToString:@"rect"]) {
                        [self addSublayer:[self createRectLayer:shape]];
                    }
                }
            }
            else if ([shape isKindOfClass:[SVGAProtoShapeEntity class]]) {
                SVGAProtoShapeEntity *shapeItem = (id)shape;
                if (shapeItem.type == SVGAProtoShapeEntity_ShapeType_Shape) {
                    [self addSublayer:[self createCurveLayerWithProto:shapeItem]];
                }
                else if (shapeItem.type == SVGAProtoShapeEntity_ShapeType_Ellipse) {
                    [self addSublayer:[self createEllipseLayerWithProto:shapeItem]];
                }
                else if (shapeItem.type == SVGAProtoShapeEntity_ShapeType_Rect) {
                    [self addSublayer:[self createRectLayerWithProto:shapeItem]];
                }
            }
        }
        self.drawedFrame = frame;
    }
}

- (CALayer *)createCurveLayer:(NSDictionary *)shape {
    SVGABezierPath *bezierPath = [SVGABezierPath new];
    if ([shape[@"args"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"args"][@"d"] isKindOfClass:[NSString class]]) {
            [bezierPath setValues:shape[@"args"][@"d"]];
        }
    }
    CAShapeLayer *shapeLayer = [bezierPath createLayer];
    [self resetStyles:shapeLayer shape:shape];
    [self resetTransform:shapeLayer shape:shape];
    return shapeLayer;
}

- (CALayer *)createCurveLayerWithProto:(SVGAProtoShapeEntity *)shape {
    SVGABezierPath *bezierPath = [SVGABezierPath new];
    if (shape.argsOneOfCase == SVGAProtoShapeEntity_Args_OneOfCase_Shape) {
        if ([shape.shape.d isKindOfClass:[NSString class]] && shape.shape.d.length > 0) {
            [bezierPath setValues:shape.shape.d];
        }
    }
    CAShapeLayer *shapeLayer = [bezierPath createLayer];
    [self resetStyles:shapeLayer protoShape:shape];
    [self resetTransform:shapeLayer protoShape:shape];
    return shapeLayer;
}

- (CALayer *)createEllipseLayer:(NSDictionary *)shape {
    UIBezierPath *bezierPath;
    if ([shape[@"args"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"args"][@"x"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"y"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"radiusX"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"radiusY"] isKindOfClass:[NSNumber class]]) {
            CGFloat x = [shape[@"args"][@"x"] floatValue];
            CGFloat y = [shape[@"args"][@"y"] floatValue];
            CGFloat rx = [shape[@"args"][@"radiusX"] floatValue];
            CGFloat ry = [shape[@"args"][@"radiusY"] floatValue];
            bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x - rx, y - ry, rx * 2, ry * 2)];
        }
    }
    if (bezierPath != nil) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setPath:[bezierPath CGPath]];
        [self resetStyles:shapeLayer shape:shape];
        [self resetTransform:shapeLayer shape:shape];
        return shapeLayer;
    }
    else {
        return [CALayer layer];
    }
}

- (CALayer *)createEllipseLayerWithProto:(SVGAProtoShapeEntity *)shape {
    UIBezierPath *bezierPath;
    if (shape.argsOneOfCase == SVGAProtoShapeEntity_Args_OneOfCase_Ellipse) {
        bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(shape.ellipse.x - shape.ellipse.radiusX,
                                                                       shape.ellipse.y - shape.ellipse.radiusY,
                                                                       shape.ellipse.radiusX * 2,
                                                                       shape.ellipse.radiusY * 2)];
    }
    if (bezierPath != nil) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setPath:[bezierPath CGPath]];
        [self resetStyles:shapeLayer protoShape:shape];
        [self resetTransform:shapeLayer protoShape:shape];
        return shapeLayer;
    }
    else {
        return [CALayer layer];
    }
}

- (CALayer *)createRectLayer:(NSDictionary *)shape {
    UIBezierPath *bezierPath;
    if ([shape[@"args"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"args"][@"x"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"y"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"width"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"height"] isKindOfClass:[NSNumber class]] &&
            [shape[@"args"][@"cornerRadius"] isKindOfClass:[NSNumber class]]) {
            CGFloat x = [shape[@"args"][@"x"] floatValue];
            CGFloat y = [shape[@"args"][@"y"] floatValue];
            CGFloat width = [shape[@"args"][@"width"] floatValue];
            CGFloat height = [shape[@"args"][@"height"] floatValue];
            CGFloat cornerRadius = [shape[@"args"][@"cornerRadius"] floatValue];
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, width, height) cornerRadius:cornerRadius];
        }
    }
    if (bezierPath != nil) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setPath:[bezierPath CGPath]];
        [self resetStyles:shapeLayer shape:shape];
        [self resetTransform:shapeLayer shape:shape];
        return shapeLayer;
    }
    else {
        return [CALayer layer];
    }
}

- (CALayer *)createRectLayerWithProto:(SVGAProtoShapeEntity *)shape {
    UIBezierPath *bezierPath;
    if (shape.argsOneOfCase == SVGAProtoShapeEntity_Args_OneOfCase_Rect) {
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(shape.rect.x, shape.rect.y, shape.rect.width, shape.rect.height)
                                                cornerRadius:shape.rect.cornerRadius];
    }
    if (bezierPath != nil) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setPath:[bezierPath CGPath]];
        [self resetStyles:shapeLayer protoShape:shape];
        [self resetTransform:shapeLayer protoShape:shape];
        return shapeLayer;
    }
    else {
        return [CALayer layer];
    }
}

- (void)resetStyles:(CAShapeLayer *)shapeLayer shape:(NSDictionary *)shape {
    shapeLayer.masksToBounds = NO;
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    if ([shape[@"styles"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"styles"][@"fill"] isKindOfClass:[NSArray class]]) {
            NSArray *colorArray = shape[@"styles"][@"fill"];
            if ([colorArray count] == 4 &&
                [colorArray[0] isKindOfClass:[NSNumber class]] &&
                [colorArray[1] isKindOfClass:[NSNumber class]] &&
                [colorArray[2] isKindOfClass:[NSNumber class]] &&
                [colorArray[3] isKindOfClass:[NSNumber class]]) {
                shapeLayer.fillColor = [UIColor colorWithRed:[colorArray[0] floatValue]
                                                       green:[colorArray[1] floatValue]
                                                        blue:[colorArray[2] floatValue]
                                                       alpha:[colorArray[3] floatValue]].CGColor;
            }
        }
        else {
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
        }
        if ([shape[@"styles"][@"stroke"] isKindOfClass:[NSArray class]]) {
            NSArray *colorArray = shape[@"styles"][@"stroke"];
            if ([colorArray count] == 4 &&
                [colorArray[0] isKindOfClass:[NSNumber class]] &&
                [colorArray[1] isKindOfClass:[NSNumber class]] &&
                [colorArray[2] isKindOfClass:[NSNumber class]] &&
                [colorArray[3] isKindOfClass:[NSNumber class]]) {
                shapeLayer.strokeColor = [UIColor colorWithRed:[colorArray[0] floatValue]
                                                         green:[colorArray[1] floatValue]
                                                          blue:[colorArray[2] floatValue]
                                                         alpha:[colorArray[3] floatValue]].CGColor;
            }
        }
        if ([shape[@"styles"][@"strokeWidth"] isKindOfClass:[NSNumber class]]) {
            shapeLayer.lineWidth = [shape[@"styles"][@"strokeWidth"] floatValue];
        }
        if ([shape[@"styles"][@"lineCap"] isKindOfClass:[NSString class]]) {
            shapeLayer.lineCap = shape[@"styles"][@"lineCap"];
        }
        if ([shape[@"styles"][@"lineJoin"] isKindOfClass:[NSString class]]) {
            shapeLayer.lineJoin = shape[@"styles"][@"lineJoin"];
        }
        if ([shape[@"styles"][@"lineDash"] isKindOfClass:[NSArray class]]) {
            BOOL accept = YES;
            for (id obj in shape[@"styles"][@"lineDash"]) {
                if (![obj isKindOfClass:[NSNumber class]]) {
                    accept = NO;
                }
            }
            if (accept) {
                if ([shape[@"styles"][@"lineDash"] count] == 3) {
                    shapeLayer.lineDashPhase = [shape[@"styles"][@"lineDash"][2] floatValue];
                    shapeLayer.lineDashPattern = @[
                                                   ([shape[@"styles"][@"lineDash"][0] floatValue] < 1.0 ? @(1.0) : shape[@"styles"][@"lineDash"][0]),
                                                   ([shape[@"styles"][@"lineDash"][1] floatValue] < 0.1 ? @(0.1) : shape[@"styles"][@"lineDash"][1])
                                                   ];
                }
            }
        }
        if ([shape[@"styles"][@"miterLimit"] isKindOfClass:[NSNumber class]]) {
            shapeLayer.miterLimit = [shape[@"styles"][@"miterLimit"] floatValue];
        }
    }
}

- (void)resetStyles:(CAShapeLayer *)shapeLayer protoShape:(SVGAProtoShapeEntity *)protoShape {
    shapeLayer.masksToBounds = NO;
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    if (protoShape.hasStyles) {
        if (protoShape.styles.hasFill) {
            shapeLayer.fillColor = [UIColor colorWithRed:protoShape.styles.fill.r
                                                   green:protoShape.styles.fill.g
                                                    blue:protoShape.styles.fill.b
                                                   alpha:protoShape.styles.fill.a].CGColor;
        }
        else {
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
        }
        if (protoShape.styles.hasStroke) {
            shapeLayer.strokeColor = [UIColor colorWithRed:protoShape.styles.stroke.r
                                                     green:protoShape.styles.stroke.g
                                                      blue:protoShape.styles.stroke.b
                                                     alpha:protoShape.styles.stroke.a].CGColor;
        }
        shapeLayer.lineWidth = protoShape.styles.strokeWidth;
        switch (protoShape.styles.lineCap) {
            case SVGAProtoShapeEntity_ShapeStyle_LineCap_LineCapButt:
                shapeLayer.lineCap = @"butt";
                break;
            case SVGAProtoShapeEntity_ShapeStyle_LineCap_LineCapRound:
                shapeLayer.lineCap = @"round";
                break;
            case SVGAProtoShapeEntity_ShapeStyle_LineCap_LineCapSquare:
                shapeLayer.lineCap = @"square";
                break;
            default:
                break;
        }
        switch (protoShape.styles.lineJoin) {
            case SVGAProtoShapeEntity_ShapeStyle_LineJoin_LineJoinRound:
                shapeLayer.lineJoin = @"round";
                break;
            case SVGAProtoShapeEntity_ShapeStyle_LineJoin_LineJoinMiter:
                shapeLayer.lineJoin = @"miter";
                break;
            case SVGAProtoShapeEntity_ShapeStyle_LineJoin_LineJoinBevel:
                shapeLayer.lineJoin = @"bevel";
                break;
            default:
                break;
        }
        shapeLayer.lineDashPhase = protoShape.styles.lineDashIii;
        if (protoShape.styles.lineDashI > 0.0 || protoShape.styles.lineDashIi > 0.0) {
            shapeLayer.lineDashPattern = @[
                                           (protoShape.styles.lineDashI < 1.0 ? @(1.0) : @(protoShape.styles.lineDashI)),
                                           (protoShape.styles.lineDashIi < 0.1 ? @(0.1) : @(protoShape.styles.lineDashIi))
                                           ];
        }
        shapeLayer.miterLimit = protoShape.styles.miterLimit;
    }
}

- (void)resetTransform:(CAShapeLayer *)shapeLayer shape:(NSDictionary *)shape {
    if ([shape[@"transform"] isKindOfClass:[NSDictionary class]]) {
        if ([shape[@"transform"][@"a"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"b"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"c"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"d"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"tx"] isKindOfClass:[NSNumber class]] &&
            [shape[@"transform"][@"ty"] isKindOfClass:[NSNumber class]]) {
            shapeLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake([shape[@"transform"][@"a"] floatValue],
                                                                                          [shape[@"transform"][@"b"] floatValue],
                                                                                          [shape[@"transform"][@"c"] floatValue],
                                                                                          [shape[@"transform"][@"d"] floatValue],
                                                                                          [shape[@"transform"][@"tx"] floatValue],
                                                                                          [shape[@"transform"][@"ty"] floatValue])
                                                                    );
        }
    }
}

- (void)resetTransform:(CAShapeLayer *)shapeLayer protoShape:(SVGAProtoShapeEntity *)protoShape {
    if (protoShape.hasTransform) {
        shapeLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake((CGFloat)protoShape.transform.a,
                                                                                      (CGFloat)protoShape.transform.b,
                                                                                      (CGFloat)protoShape.transform.c,
                                                                                      (CGFloat)protoShape.transform.d,
                                                                                      (CGFloat)protoShape.transform.tx,
                                                                                      (CGFloat)protoShape.transform.ty)
                                                                );
    }
}

@end

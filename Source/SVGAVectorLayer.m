//
//  SVGAVectorLayer.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/20.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "SVGAVectorLayer.h"
#import "SVGABezierPath.h"

@interface SVGAVectorLayer ()

@property (nonatomic, strong) NSArray *spec;

@end

@implementation SVGAVectorLayer

- (instancetype)initWithSpec:(NSArray *)spec previous:(SVGAVectorLayer *)previous
{
    self = [super init];
    if (self) {
        _spec = spec;
        self.masksToBounds = NO;
        [self createSublayers:previous];
    }
    return self;
}

- (void)createSublayers:(SVGAVectorLayer *)previous {
    for (NSDictionary *shape in self.spec) {
        if ([shape isKindOfClass:[NSDictionary class]]) {
            if ([shape[@"type"] isKindOfClass:[NSString class]]) {
                if ([shape[@"type"] isEqualToString:@"shape"]) {
                    [self addSublayer:[self createCurveLayer:shape]];
                }
                else if ([shape[@"type"] isEqualToString:@"ellipse"]) {
                    [self addSublayer:[self createEllipseLayer:shape]];
                }
                else if ([shape[@"type"] isEqualToString:@"keep"] && previous != nil) {
                    for (CALayer *item in previous.sublayers) {
                        [self addSublayer:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:item]]];
                    }
                }
            }
        }
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
            CGFloat y = [shape[@"args"][@"x"] floatValue];
            CGFloat rx = [shape[@"args"][@"radiusX"] floatValue];
            CGFloat ry = [shape[@"args"][@"radiusY"] floatValue];
            bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x - rx, y - ry, rx * 2, ry * 2)];
        }
    }
    if (bezierPath != nil) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setPath:[bezierPath CGPath]];
        [self resetStyles:shapeLayer shape:shape];
        return shapeLayer;
    }
    else {
        return [CALayer layer];
    }
}

- (void)resetStyles:(CAShapeLayer *)shapeLayer shape:(NSDictionary *)shape {
    shapeLayer.masksToBounds = NO;
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
    }
}

@end

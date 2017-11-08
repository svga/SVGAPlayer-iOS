//
//  SVGABezierPath.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/28.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGABezierPath.h"

@interface SVGABezierPath ()

@property (nonatomic, assign) BOOL displaying;
@property (nonatomic, copy) NSString *backValues;

@end

@implementation SVGABezierPath

- (void)setValues:(nonnull NSString *)values {
    if (!self.displaying) {
        self.backValues = values;
        return;
    }
    static NSSet *validMethods;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        validMethods = [NSSet setWithArray:@[@"M",@"L",@"H",@"V",@"C",@"S",@"Q",@"R",@"A",@"Z",@"m",@"l",@"h",@"v",@"c",@"s",@"q",@"r",@"a",@"z"]];
    });
    values = [values stringByReplacingOccurrencesOfString:@"([a-zA-Z])" withString:@"|||$1 " options:NSRegularExpressionSearch range:NSMakeRange(0, values.length)];
    values = [values stringByReplacingOccurrencesOfString:@"," withString:@" "];
    NSArray<NSString *> *segments = [values componentsSeparatedByString:@"|||"];
    for (NSString *segment in segments) {
        if (segment.length == 0) {
            continue;
        }
        NSString *firstLetter = [segment substringToIndex:1];
        if ([validMethods containsObject:firstLetter]) {
            NSArray *args = [[[segment substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "];
            [self operate:firstLetter args:args];
        }
    }
}

- (nonnull CAShapeLayer *)createLayer {
    if (!self.displaying) {
        self.displaying = YES;
        [self setValues:self.backValues];
    }
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = self.CGPath;
    layer.fillColor = [UIColor blackColor].CGColor;
    return layer;
}

- (void)operate:(NSString *)method args:(NSArray<NSString *> *)args {
    if (([method isEqualToString:@"M"] || [method isEqualToString:@"m"]) && args.count == 2) {
        CGPoint iPoint = [self argPoint:CGPointMake([args[0] floatValue], [args[1] floatValue]) relative:[method isEqualToString:@"m"]];
        if (!CGPointEqualToPoint(iPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN))) {
            [self moveToPoint:iPoint];
        }
    }
    else if (([method isEqualToString:@"L"] || [method isEqualToString:@"l"]) && args.count == 2) {
        CGPoint iPoint = [self argPoint:CGPointMake([args[0] floatValue], [args[1] floatValue]) relative:[method isEqualToString:@"l"]];
        if (!CGPointEqualToPoint(iPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN))) {
            [self addLineToPoint:iPoint];
        }
    }
    else if (([method isEqualToString:@"C"] || [method isEqualToString:@"c"]) && args.count == 6) {
        CGPoint iPoint = [self argPoint:CGPointMake([args[0] floatValue], [args[1] floatValue]) relative:[method isEqualToString:@"c"]];
        CGPoint iiPoint = [self argPoint:CGPointMake([args[2] floatValue], [args[3] floatValue]) relative:[method isEqualToString:@"c"]];
        CGPoint iiiPoint = [self argPoint:CGPointMake([args[4] floatValue], [args[5] floatValue]) relative:[method isEqualToString:@"c"]];
        if (!CGPointEqualToPoint(iPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN)) &&
            !CGPointEqualToPoint(iiPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN)) &&
            !CGPointEqualToPoint(iiiPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN))) {
            [self addCurveToPoint:iiiPoint controlPoint1:iPoint controlPoint2:iiPoint];
        }
    }
    else if (([method isEqualToString:@"Q"] || [method isEqualToString:@"q"]) && args.count == 4) {
        CGPoint iPoint = [self argPoint:CGPointMake([args[0] floatValue], [args[1] floatValue]) relative:[method isEqualToString:@"q"]];
        CGPoint iiPoint = [self argPoint:CGPointMake([args[2] floatValue], [args[3] floatValue]) relative:[method isEqualToString:@"q"]];
        if (!CGPointEqualToPoint(iPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN)) &&
            !CGPointEqualToPoint(iiPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN))) {
            [self addQuadCurveToPoint:iiPoint controlPoint:iPoint];
        }
    }
    else if (([method isEqualToString:@"H"] || [method isEqualToString:@"h"]) && args.count == 1) {
        CGFloat iValue = [self argFloat:args[0].floatValue relativeValue:([method isEqualToString:@"h"] ? self.currentPoint.x : 0.0)];
        if (iValue != CGFLOAT_MIN) {
            [self addLineToPoint:CGPointMake(iValue, self.currentPoint.y)];
        }
    }
    else if (([method isEqualToString:@"V"] || [method isEqualToString:@"v"]) && args.count == 1) {
        CGFloat iValue = [self argFloat:args[0].floatValue relativeValue:([method isEqualToString:@"v"] ? self.currentPoint.y : 0.0)];
        if (iValue != CGFLOAT_MIN) {
            [self addLineToPoint:CGPointMake(self.currentPoint.x, iValue)];
        }
    }
    else if (([method isEqualToString:@"Z"] || [method isEqualToString:@"z"])) {
        [self closePath];
    }
}

- (CGFloat)argFloat:(CGFloat)value relativeValue:(CGFloat)relativeValue {
    return value + relativeValue;
}

- (CGPoint)argPoint:(CGPoint)point relative:(BOOL)relative {
    if (relative) {
        return CGPointMake(point.x + self.currentPoint.x, point.y + self.currentPoint.y);
    }
    else {
        return point;
    }
}

@end

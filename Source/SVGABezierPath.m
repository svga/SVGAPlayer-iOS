//
//  SVGABezierPath.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/28.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGABezierPath.h"

@implementation SVGABezierPath

- (void)setValues:(nonnull NSString *)values {
    static NSMutableDictionary *caches;
    static NSArray *validMethods;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        caches = [NSMutableDictionary dictionary];
        validMethods = @[@"M",@"L",@"H",@"V",@"C",@"S",@"Q",@"R",@"A",@"Z",@"m",@"l",@"h",@"v",@"c",@"s",@"q",@"r",@"a",@"z"];
    });
    if ([caches objectForKey:values] != nil) {
        [self appendPath:[caches objectForKey:values]];
        return;
    }
    values = [values stringByReplacingOccurrencesOfString:@"," withString:@" "];
    NSArray<NSString *> *items = [values componentsSeparatedByString:@" "];
    NSString *currentMethod = @"";
    NSMutableArray<NSString *> *args = [NSMutableArray array];
    NSString *argLast = nil;
    for (NSString *item in items) {
        if (item.length < 1) {
            continue;
        }
        NSString *firstLetter = [item substringToIndex:1];
        if ([validMethods indexOfObject:firstLetter] != NSNotFound) {
            if (argLast != nil) {
                [args addObject:argLast];
            }
            [self operate:currentMethod args:[args copy]];
            currentMethod = @"";
            [args removeAllObjects];
            argLast = nil;
            currentMethod = firstLetter;
            argLast = [item substringFromIndex:1];
        }
        else {
            if (argLast != nil && [argLast stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
                [args addObject:[NSString stringWithFormat:@"%@,%@", argLast, item]];
                argLast = nil;
            }
            else {
                argLast = item;
            }
        }
    }
    [self operate:currentMethod args:[args copy]];
    [caches setObject:self forKey:values];
}

- (nonnull CAShapeLayer *)createLayer {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = self.CGPath;
    layer.fillColor = [UIColor blackColor].CGColor;
    return layer;
}

- (void)operate:(NSString *)method args:(NSArray<NSString *> *)args {
    if (([method isEqualToString:@"M"] || [method isEqualToString:@"m"]) && args.count == 1) {
        CGPoint iPoint = [self argPoint:args[0] relative:[method isEqualToString:@"m"]];
        if (!CGPointEqualToPoint(iPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN))) {
            [self moveToPoint:iPoint];
        }
    }
    else if (([method isEqualToString:@"L"] || [method isEqualToString:@"l"]) && args.count == 1) {
        CGPoint iPoint = [self argPoint:args[0] relative:[method isEqualToString:@"l"]];
        if (!CGPointEqualToPoint(iPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN))) {
            [self addLineToPoint:iPoint];
        }
    }
    else if (([method isEqualToString:@"C"] || [method isEqualToString:@"c"]) && args.count == 3) {
        CGPoint iPoint = [self argPoint:args[0] relative:[method isEqualToString:@"c"]];
        CGPoint iiPoint = [self argPoint:args[1] relative:[method isEqualToString:@"c"]];
        CGPoint iiiPoint = [self argPoint:args[2] relative:[method isEqualToString:@"c"]];
        if (!CGPointEqualToPoint(iPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN)) &&
            !CGPointEqualToPoint(iiPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN)) &&
            !CGPointEqualToPoint(iiiPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN))) {
            [self addCurveToPoint:iiiPoint controlPoint1:iPoint controlPoint2:iiPoint];
        }
    }
    else if (([method isEqualToString:@"Q"] || [method isEqualToString:@"q"]) && args.count == 2) {
        CGPoint iPoint = [self argPoint:args[0] relative:[method isEqualToString:@"q"]];
        CGPoint iiPoint = [self argPoint:args[1] relative:[method isEqualToString:@"q"]];
        if (!CGPointEqualToPoint(iPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN)) &&
            !CGPointEqualToPoint(iiPoint, CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN))) {
            [self addQuadCurveToPoint:iiPoint controlPoint:iPoint];
        }
    }
    else if (([method isEqualToString:@"H"] || [method isEqualToString:@"h"]) && args.count == 1) {
        CGFloat iValue = [self argFloat:args[0] relativeValue:([method isEqualToString:@"h"] ? self.currentPoint.x : 0.0)];
        if (iValue != CGFLOAT_MIN) {
            [self addLineToPoint:CGPointMake(iValue, self.currentPoint.y)];
        }
    }
    else if (([method isEqualToString:@"V"] || [method isEqualToString:@"v"]) && args.count == 1) {
        CGFloat iValue = [self argFloat:args[0] relativeValue:([method isEqualToString:@"v"] ? self.currentPoint.y : 0.0)];
        if (iValue != CGFLOAT_MIN) {
            [self addLineToPoint:CGPointMake(self.currentPoint.x, iValue)];
        }
    }
    else if (([method isEqualToString:@"Z"] || [method isEqualToString:@"z"]) && args.count == 1) {
        [self closePath];
    }
}

- (CGFloat)argFloat:(NSString *)arg relativeValue:(CGFloat)relativeValue {
    NSNumberFormatter *numberFotmatter = [[NSNumberFormatter alloc] init];
    NSNumber *x = [numberFotmatter numberFromString:arg];
    if (x != nil) {
        return x.floatValue + relativeValue;
    }
    else {
        return CGFLOAT_MIN;
    }
}

- (CGPoint)argPoint:(NSString *)arg relative:(BOOL)relative {
    if ([arg componentsSeparatedByString:@","].count == 2) {
        NSNumberFormatter *numberFotmatter = [[NSNumberFormatter alloc] init];
        NSNumber *x = [numberFotmatter numberFromString:[arg componentsSeparatedByString:@","][0]];
        NSNumber *y = [numberFotmatter numberFromString:[arg componentsSeparatedByString:@","][1]];
        if (x != nil && y != nil) {
            if (relative) {
                return CGPointMake(x.floatValue + self.currentPoint.x, y.floatValue + self.currentPoint.y);
            }
            else {
                return CGPointMake(x.floatValue, y.floatValue);
            }
        }
    }
    return CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
}

@end

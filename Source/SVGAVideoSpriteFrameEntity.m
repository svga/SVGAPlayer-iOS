//
//  SVGAVideoSpriteFrameEntity.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/20.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "SVGAVideoSpriteFrameEntity.h"
#import "SVGAVectorLayer.h"
#import "SVGABezierPath.h"

@interface SVGAVideoSpriteFrameEntity ()

@property (nonatomic, strong) SVGAVideoSpriteFrameEntity *previousFrame;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, assign) CGRect layout;
@property (nonatomic, assign) CGFloat nx;
@property (nonatomic, assign) CGFloat ny;
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) NSArray *shapes;

@end

@implementation SVGAVideoSpriteFrameEntity

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    self = [super init];
    if (self) {
        _alpha = 0.0;
        _layout = CGRectZero;
        _transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
        if ([JSONObject isKindOfClass:[NSDictionary class]]) {
            NSNumber *alpha = JSONObject[@"alpha"];
            if ([alpha isKindOfClass:[NSNumber class]]) {
                _alpha = [alpha floatValue];
            }
            NSDictionary *layout = JSONObject[@"layout"];
            if ([layout isKindOfClass:[NSDictionary class]]) {
                NSNumber *x = layout[@"x"];
                NSNumber *y = layout[@"y"];
                NSNumber *width = layout[@"width"];
                NSNumber *height = layout[@"height"];
                if ([x isKindOfClass:[NSNumber class]] && [y isKindOfClass:[NSNumber class]] && [width isKindOfClass:[NSNumber class]] && [height isKindOfClass:[NSNumber class]]) {
                    _layout = CGRectMake(x.floatValue, y.floatValue, width.floatValue, height.floatValue);
                }
            }
            NSDictionary *transform = JSONObject[@"transform"];
            if ([transform isKindOfClass:[NSDictionary class]]) {
                NSNumber *a = transform[@"a"];
                NSNumber *b = transform[@"b"];
                NSNumber *c = transform[@"c"];
                NSNumber *d = transform[@"d"];
                NSNumber *tx = transform[@"tx"];
                NSNumber *ty = transform[@"ty"];
                if ([a isKindOfClass:[NSNumber class]] && [b isKindOfClass:[NSNumber class]] && [c isKindOfClass:[NSNumber class]] && [d isKindOfClass:[NSNumber class]] && [tx isKindOfClass:[NSNumber class]] && [ty isKindOfClass:[NSNumber class]]) {
                    _transform = CGAffineTransformMake(a.floatValue, b.floatValue, c.floatValue, d.floatValue, tx.floatValue, ty.floatValue);
                }
            }
            NSString *clipPath = JSONObject[@"clipPath"];
            if ([clipPath isKindOfClass:[NSString class]]) {
                SVGABezierPath *bezierPath = [[SVGABezierPath alloc] init];
                [bezierPath setValues:clipPath];
                self.maskLayer = [bezierPath createLayer];
            }
            NSArray *shapes = JSONObject[@"shapes"];
            if ([shapes isKindOfClass:[NSArray class]]) {
                _shapes = shapes;
            }
        }
        CGFloat llx = _transform.a * _layout.origin.x + _transform.c * _layout.origin.y + _transform.tx;
        CGFloat lrx = _transform.a * (_layout.origin.x + _layout.size.width) + _transform.c * _layout.origin.y + _transform.tx;
        CGFloat lbx = _transform.a * _layout.origin.x + _transform.c * (_layout.origin.y + _layout.size.height) + _transform.tx;
        CGFloat rbx = _transform.a * (_layout.origin.x + _layout.size.width) + _transform.c * (_layout.origin.y + _layout.size.height) + _transform.tx;
        CGFloat lly = _transform.b * _layout.origin.x + _transform.d * _layout.origin.y + _transform.ty;
        CGFloat lry = _transform.b * (_layout.origin.x + _layout.size.width) + _transform.d * _layout.origin.y + _transform.ty;
        CGFloat lby = _transform.b * _layout.origin.x + _transform.d * (_layout.origin.y + _layout.size.height) + _transform.ty;
        CGFloat rby = _transform.b * (_layout.origin.x + _layout.size.width) + _transform.d * (_layout.origin.y + _layout.size.height) + _transform.ty;
        _nx = MIN(MIN(lbx,  rbx), MIN(llx, lrx));
        _ny = MIN(MIN(lby,  rby), MIN(lly, lry));
    }
    return self;
}

@end

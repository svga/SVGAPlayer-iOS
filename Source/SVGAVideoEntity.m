//
//  SVGAVideoEntity.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGAVideoEntity.h"

@implementation SVGAVideoEntity

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    self = [super init];
    if (self) {
        _videoSize = CGSizeMake(100, 100);
        _FPS = 20;
        _images = @{};
        if ([JSONObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *viewBox = JSONObject[@"viewBox"];
            if ([viewBox isKindOfClass:[NSDictionary class]]) {
                NSNumber *width = viewBox[@"width"];
                NSNumber *height = viewBox[@"height"];
                if ([width isKindOfClass:[NSNumber class]] && [height isKindOfClass:[NSNumber class]]) {
                    _videoSize = CGSizeMake(width.floatValue, height.floatValue);
                }
            }
            NSNumber *FPS = JSONObject[@"FPS"];
            if ([FPS isKindOfClass:[NSNumber class]]) {
                _FPS = [FPS intValue];
            }
        }
    }
    return self;
}

- (void)resetImagesWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary<NSString *, UIImage *> *images = [[NSMutableDictionary alloc] init];
        NSDictionary<NSString *, NSString *> *JSONImages = JSONObject[@"images"];
        if ([JSONImages isKindOfClass:[NSDictionary class]]) {
            [JSONImages enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:obj options:kNilOptions];
                    if (imageData != nil) {
                        UIImage *image = [[UIImage alloc] initWithData:imageData scale:2.0];
                        if (image != nil) {
                            [images setObject:image forKey:key];
                        }
                    }
                }
            }];
        }
        self.images = images;
    }
}

- (void)resetSpritesWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableArray<SVGAVideoSpriteEntity *> *sprites = [[NSMutableArray alloc] init];
        NSArray<NSDictionary *> *JSONSprites = JSONObject[@"sprites"];
        if ([JSONSprites isKindOfClass:[NSArray class]]) {
            [JSONSprites enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    SVGAVideoSpriteEntity *spriteItem = [[SVGAVideoSpriteEntity alloc] initWithJSONObject:obj];
                    [sprites addObject:spriteItem];
                }
            }];
        }
        self.sprites = sprites;
    }
}

@end

@implementation SVGAVideoSpriteEntity

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    self = [super init];
    if (self) {
        if ([JSONObject isKindOfClass:[NSDictionary class]]) {
            NSString *sKey = JSONObject[@"sKey"];
            NSArray<NSDictionary *> *JSONFrames = JSONObject[@"frames"];
            if ([sKey isKindOfClass:[NSString class]] && [JSONFrames isKindOfClass:[NSArray class]]) {
                NSMutableArray<SVGAVideoSpriteFrameEntity *> *frames = [[NSMutableArray alloc] init];
                [JSONFrames enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        [frames addObject:[[SVGAVideoSpriteFrameEntity alloc] initWithJSONObject:obj]];
                    }
                }];
                _sKey = sKey;
                _frames = frames;
            }
        }
    }
    return self;
}

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
        }
    }
    return self;
}

@end
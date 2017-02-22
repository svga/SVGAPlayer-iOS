//
//  SVGAVideoSpriteEntity.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/20.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "SVGAVideoSpriteEntity.h"
#import "SVGAVideoSpriteFrameEntity.h"
#import "SVGABitmapLayer.h"
#import "SVGAContentLayer.h"
#import "SVGAVectorLayer.h"

@implementation SVGAVideoSpriteEntity

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    self = [super init];
    if (self) {
        if ([JSONObject isKindOfClass:[NSDictionary class]]) {
            NSString *imageKey = JSONObject[@"imageKey"];
            NSArray<NSDictionary *> *JSONFrames = JSONObject[@"frames"];
            if ([imageKey isKindOfClass:[NSString class]] && [JSONFrames isKindOfClass:[NSArray class]]) {
                NSMutableArray<SVGAVideoSpriteFrameEntity *> *frames = [[NSMutableArray alloc] init];
                [JSONFrames enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        [frames addObject:[[SVGAVideoSpriteFrameEntity alloc] initWithJSONObject:obj]];
                    }
                }];
                _imageKey = imageKey;
                _frames = frames;
            }
        }
    }
    return self;
}

- (SVGAContentLayer *)requestLayerWithBitmap:(UIImage *)bitmap {
    SVGAContentLayer *layer = [[SVGAContentLayer alloc] initWithFrames:self.frames];
    if (bitmap != nil) {
        layer.bitmapLayer = [[SVGABitmapLayer alloc] initWithFrames:self.frames];
        layer.bitmapLayer.contents = (__bridge id _Nullable)([bitmap CGImage]);
    }
    layer.vectorLayer = [[SVGAVectorLayer alloc] initWithFrames:self.frames];
    return layer;
}

@end

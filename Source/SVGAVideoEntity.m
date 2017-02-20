//
//  SVGAVideoEntity.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGAVideoEntity.h"
#import "SVGABezierPath.h"
#import "SVGAVideoSpriteEntity.h"

@interface SVGAVideoEntity ()

@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) int FPS;
@property (nonatomic, assign) int frames;
@property (nonatomic, copy) NSDictionary<NSString *, UIImage *> *images;
@property (nonatomic, copy) NSArray<SVGAVideoSpriteEntity *> *sprites;
@property (nonatomic, copy) NSString *cacheDir;

@end

@implementation SVGAVideoEntity

static NSCache *videoCache;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        videoCache = [[NSCache alloc] init];
    });
}

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject cacheDir:(NSString *)cacheDir {
    self = [super init];
    if (self) {
        _videoSize = CGSizeMake(100, 100);
        _FPS = 20;
        _images = @{};
        _cacheDir = cacheDir;
        [self resetMovieWithJSONObject:JSONObject];
    }
    return self;
}

- (void)resetMovieWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *movieObject = JSONObject[@"movie"];
        if ([movieObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *viewBox = movieObject[@"viewBox"];
            if ([viewBox isKindOfClass:[NSDictionary class]]) {
                NSNumber *width = viewBox[@"width"];
                NSNumber *height = viewBox[@"height"];
                if ([width isKindOfClass:[NSNumber class]] && [height isKindOfClass:[NSNumber class]]) {
                    _videoSize = CGSizeMake(width.floatValue, height.floatValue);
                }
            }
            NSNumber *FPS = movieObject[@"fps"];
            if ([FPS isKindOfClass:[NSNumber class]]) {
                _FPS = [FPS intValue];
            }
            NSNumber *frames = movieObject[@"frames"];
            if ([frames isKindOfClass:[NSNumber class]]) {
                _frames = [frames intValue];
            }
        }
    }
}

- (void)resetImagesWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary<NSString *, UIImage *> *images = [[NSMutableDictionary alloc] init];
        NSDictionary<NSString *, NSString *> *JSONImages = JSONObject[@"images"];
        if ([JSONImages isKindOfClass:[NSDictionary class]]) {
            [JSONImages enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    NSString *filePath = [self.cacheDir stringByAppendingFormat:@"/%@.png", obj];
                    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
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

+ (SVGAVideoEntity *)readCache:(NSString *)cacheKey {
    return [videoCache objectForKey:cacheKey];
}

- (void)saveCache:(NSString *)cacheKey {
    [videoCache setObject:self forKey:cacheKey];
}

@end

@interface SVGAVideoSpriteEntity()

@property (nonatomic, copy) NSString *imageKey;
@property (nonatomic, copy) NSArray<SVGAVideoSpriteFrameEntity *> *frames;

@end


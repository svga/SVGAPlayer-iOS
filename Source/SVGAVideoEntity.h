//
//  SVGAVideoEntity.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SVGAVideoEntity, SVGAVideoSpriteEntity, SVGAVideoSpriteFrameEntity, SVGABitmapLayer, SVGAVectorLayer, SVGAAudioEntity;
@class SVGAProtoMovieEntity;

@interface SVGAVideoEntity : NSObject

@property (nonatomic, readonly) CGSize videoSize;
@property (nonatomic, readonly) int FPS;
@property (nonatomic, readonly) int frames;
// 所有图片的总像素数（像素数决定了占用内存的大小）
@property (nonatomic, readonly) NSUInteger totalPixelCount;
@property (nonatomic, readonly) NSDictionary<NSString *, UIImage *> *images;
@property (nonatomic, readonly) NSDictionary<NSString *, NSData *> *audiosData;
@property (nonatomic, readonly) NSArray<SVGAVideoSpriteEntity *> *sprites;
@property (nonatomic, readonly) NSArray<SVGAAudioEntity *> *audios;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject cacheDir:(NSString *)cacheDir;
- (void)resetImagesWithJSONObject:(NSDictionary *)JSONObject;
- (void)resetSpritesWithJSONObject:(NSDictionary *)JSONObject;

- (instancetype)initWithProtoObject:(SVGAProtoMovieEntity *)protoObject cacheDir:(NSString *)cacheDir;
- (void)resetImagesWithProtoObject:(SVGAProtoMovieEntity *)protoObject;
- (void)resetSpritesWithProtoObject:(SVGAProtoMovieEntity *)protoObject;
- (void)resetAudiosWithProtoObject:(SVGAProtoMovieEntity *)protoObject;

+ (SVGAVideoEntity *)readCache:(NSString *)cacheKey;

- (void)saveCache:(NSString *)cacheKey;
// NSMapTable弱缓存
- (void)saveWeakCache:(NSString *)cacheKey;
@end



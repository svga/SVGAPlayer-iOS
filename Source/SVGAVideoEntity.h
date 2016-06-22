//
//  SVGAVideoEntity.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SVGAVideoEntity, SVGAVideoSpriteEntity, SVGAVideoSpriteFrameEntity;

@interface SVGAVideoEntity : NSObject

@property (nonatomic, readonly) CGSize videoSize;
@property (nonatomic, readonly) int FPS;
@property (nonatomic, readonly) int frames;
@property (nonatomic, readonly) NSDictionary<NSString *, UIImage *> *images;
@property (nonatomic, readonly) NSArray<SVGAVideoSpriteEntity *> *sprites;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject cacheDir:(NSString *)cacheDir;
- (void)resetImagesWithJSONObject:(NSDictionary *)JSONObject;
- (void)resetSpritesWithJSONObject:(NSDictionary *)JSONObject;

@end

@interface SVGAVideoSpriteEntity : NSObject

@property (nonatomic, readonly) NSString *imageKey;
@property (nonatomic, readonly) NSArray<SVGAVideoSpriteFrameEntity *> *frames;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;

@end

@interface SVGAVideoSpriteFrameEntity : NSObject

@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) CGAffineTransform transform;
@property (nonatomic, readonly) CGRect layout;
@property (nonatomic, readonly) CGFloat nx;
@property (nonatomic, readonly) CGFloat ny;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;

@end

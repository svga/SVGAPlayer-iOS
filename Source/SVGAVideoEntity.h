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

@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) int FPS;
@property (nonatomic, copy) NSDictionary<NSString *, UIImage *> *images;
@property (nonatomic, copy) NSArray<SVGAVideoSpriteEntity *> *sprites;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;
- (void)resetImagesWithJSONObject:(NSDictionary *)JSONObject;
- (void)resetSpritesWithJSONObject:(NSDictionary *)JSONObject;

@end

@interface SVGAVideoSpriteEntity : NSObject

@property (nonatomic, copy) NSString *sKey;
@property (nonatomic, copy) NSArray<SVGAVideoSpriteFrameEntity *> *frames;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;

@end

@interface SVGAVideoSpriteFrameEntity : NSObject

@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, assign) CGRect layout;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;

@end

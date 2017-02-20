//
//  SVGAVideoSpriteEntity.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/20.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SVGAVideoSpriteFrameEntity;

@interface SVGAVideoSpriteEntity : NSObject

@property (nonatomic, readonly) NSString *imageKey;
@property (nonatomic, readonly) NSArray<SVGAVideoSpriteFrameEntity *> *frames;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;

@end

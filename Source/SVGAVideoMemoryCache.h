//
//  SVGAVideoMemoryCache.h
//  SVGAPlayer
//
//  Created by MOMO@song.meng on 2020/7/4.
//  Copyright © 2020 UED Center. All rights reserved.
//
//  用于处理SVGA内存缓存
//

#import <Foundation/Foundation.h>
#import "SVGAVideoEntity.h"
#import "SVGAVideoEntity+mm.h"

NS_ASSUME_NONNULL_BEGIN

@interface SVGAVideoMemoryCache : NSObject


/// 是否显示内存占用tip，开启统计后才生效，默认为NO
@property (nonatomic, assign) BOOL showMemoryCostTip;
@property (nonatomic, assign) CGRect memoryCostTipFrame;

/// 内存使用限制
@property (nonatomic, assign) NSUInteger memoryCostLimit;

/// 内存使用情况，在statisticsMemoryCost为YES的情况下有效
@property (nonatomic, readonly) NSUInteger totalMemoryCost;

/// 内存缓存是否生效，默认为YES，为NO时将使用weak缓存
/// 以避免同一时刻多个SVGAPlayer使用同一资源造成重复的内存占用
/// 关闭后内存使用统计和内存占用提示将失效
@property (nonatomic, assign) BOOL memoryCacheEnable;

+ (instancetype)sharedCache;


- (void)setObject:(SVGAVideoEntity *)object forKey:(id)key;
- (SVGAVideoEntity *)objectForKey:(id)key;
- (void)removeAllObjects;
- (void)removeObjectForKey:(id)key;

@end

NS_ASSUME_NONNULL_END

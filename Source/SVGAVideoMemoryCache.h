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
#import "SVGAVideoEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface SVGAVideoMemoryCache : NSObject


/// 是否显示内存占用tip，开启统计后才生效，默认为NO，debug环境下默认为YES
@property (nonatomic, assign) BOOL showMemoryCostTip;

/// 设置内存占用显示位置
@property (nonatomic, assign) CGRect memoryCostTipFrame;

/// 内存使用限制
@property (nonatomic, assign) NSUInteger memoryCostLimit;

/// 内存使用情况，在statisticsMemoryCost为YES的情况下有效
@property (nonatomic, readonly) NSUInteger totalMemoryCost;

/// 内存缓存是否生效，默认为YES，为NO时将使用weak缓存
/// 以避免同一时刻多个SVGAPlayer使用同一资源造成重复的内存占用
/// 关闭后内存使用统计和内存占用提示将失效
@property (nonatomic, assign) BOOL memoryCacheEnable;

/// 退后台是否自动清理，默认为YES
@property (nonatomic, assign) BOOL clearInBackground;

+ (instancetype)sharedCache;


- (void)setObject:(SVGAVideoEntity *)object forKey:(id)key;
- (SVGAVideoEntity *)objectForKey:(id)key;
- (void)removeAllObjects;
- (void)removeObjectForKey:(id)key;

/// 当图片资源被替换时更新内存占用
/// @param cost 内存占用情况
- (void)updateCost:(NSInteger)cost;

@end

NS_ASSUME_NONNULL_END

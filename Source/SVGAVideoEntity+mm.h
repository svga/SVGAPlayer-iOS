//
//  SVGAVideoEntity+mm.h
//  SVGAPlayer
//
//  Created by MOMO@song.meng on 2020/7/4.
//  Copyright © 2020 UED Center. All rights reserved.
//

#import "SVGAVideoEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface SVGAVideoEntity (mm)

/// 返回内存占用情况
- (NSUInteger)getMemoryCost;

/// 重置内存占用计算
- (void)resetMemoryCost;

@end

NS_ASSUME_NONNULL_END

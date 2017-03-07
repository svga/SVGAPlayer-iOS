//
//  SVGAExporter.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/3/7.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVGAVideoEntity;

@interface SVGAExporter : NSObject

@property (nonatomic, strong) SVGAVideoEntity *videoItem;

- (NSArray<UIImage *> *)toImages;

- (void)saveImages:(NSString *)toPath filePrefix:(NSString *)filePrefix;

@end

//
//  SVGAPlayer.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVGAVideoEntity;

@interface SVGAPlayer : UIView

@property (nonatomic, strong) SVGAVideoEntity *videoItem;
@property (nonatomic, assign) int loops;
@property (nonatomic, assign) BOOL clearsAfterStop;


- (void)startAnimation;
- (void)stopAnimation;
- (void)clear;

@end

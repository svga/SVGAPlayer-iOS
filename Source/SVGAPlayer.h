//
//  SVGAPlayer.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVGAVideoEntity, SVGAPlayer;

@protocol SVGAPlayerDelegate <NSObject>

@optional
- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player;

@end

@interface SVGAPlayer : UIView

@property (nonatomic, weak) id<SVGAPlayerDelegate> delegate;
@property (nonatomic, strong) SVGAVideoEntity *videoItem;
@property (nonatomic, assign) int loops;
@property (nonatomic, assign) BOOL clearsAfterStop;

- (void)startAnimation;
- (void)stopAnimation;
- (void)clear;

#pragma mark - Dynamic Object

- (void)setImage:(UIImage *)image forKey:(NSString *)aKey referenceLayer:(CALayer *)referenceLayer;
- (void)setAttributedText:(NSAttributedString *)attributedText forKey:(NSString *)aKey;
- (void)clearDynamicObjects;

@end

//
//  SVGAImageView.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/10/17.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "SVGAPlayer.h"

@interface SVGAImageView : SVGAPlayer

@property (nonatomic, assign) IBInspectable BOOL autoPlay;
@property (nonatomic, strong) IBInspectable NSString *imageName;

@end

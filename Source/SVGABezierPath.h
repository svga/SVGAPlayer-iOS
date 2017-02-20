//
//  SVGABezierPath.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/28.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SVGABezierPath : UIBezierPath

- (void)setValues:(nonnull NSString *)values;

- (nonnull CAShapeLayer *)createLayer;

@end

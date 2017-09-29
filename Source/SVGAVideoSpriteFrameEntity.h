//
//  SVGAVideoSpriteFrameEntity.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 2017/2/20.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SVGAVectorLayer;
@class SVGAProtoFrameEntity;

@interface SVGAVideoSpriteFrameEntity : NSObject

@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) CGAffineTransform transform;
@property (nonatomic, readonly) CGRect layout;
@property (nonatomic, readonly) CGFloat nx;
@property (nonatomic, readonly) CGFloat ny;
@property (nonatomic, readonly) CALayer *maskLayer;
@property (nonatomic, readonly) NSArray *shapes;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;
- (instancetype)initWithProtoObject:(SVGAProtoFrameEntity *)protoObject;

@end

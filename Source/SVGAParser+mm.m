//
//  SVGAParser+mm.m
//  SVGAPlayer
//
//  Created by MOMO@song.meng on 2020/7/4.
//  Copyright © 2020 UED Center. All rights reserved.
//

#import "SVGAParser+mm.h"

@implementation SVGAParser (mm)

- (instancetype)init{
    if (self = [super init]) {
        self.enabledMemoryCache = YES;
    }
    return self;
}

@end

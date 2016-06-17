//
//  SVGADownloader.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVGADownloader : NSObject

- (void)loadDataWithURL:(NSURL *)URL completionBlock:(void (^)(NSData *data))completionBlock failureBlock:(void (^)(NSError *error))failureBlock;

@end

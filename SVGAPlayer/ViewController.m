//
//  ViewController.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "ViewController.h"
#import "SVGA.h"

@interface ViewController ()<SVGAPlayerDelegate>

@property (nonatomic, strong) SVGAPlayer *aPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.aPlayer];
    self.aPlayer.delegate = self;
    self.aPlayer.frame = CGRectMake(0, 0, 320, 100);
    self.aPlayer.loops = 0;
    self.aPlayer.clearsAfterStop = YES;
    SVGAParser *parser = [[SVGAParser alloc] init];
    
//    [parser parseWithURL:[NSURL URLWithString:@"http://uedfe.yypm.com/assets/svga-me/rose.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
//        if (videoItem != nil) {
//            self.aPlayer.videoItem = videoItem;
//            [self.aPlayer startAnimation];
//        }
//    } failureBlock:nil];
    
    // Dynamic Object Sample
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://img.hb.aicdn.com/80cc8e001ccdc54febd448dc45119b4bd7924ea5530b-RllWp3_sq320"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            UIImage *iconImage = [UIImage imageWithData:data];
            if (iconImage != nil) {
                [parser parseWithURL:[NSURL URLWithString:@"http://uedfe.yypm.com/assets/svga-me/kingset_dyn.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
                    if (videoItem != nil) {
                        {
                            CALayer *iconLayer = [CALayer layer];
                            iconLayer.cornerRadius = 84.0;
                            iconLayer.masksToBounds = YES;
                            iconLayer.borderWidth = 4.0;
                            iconLayer.borderColor = [UIColor colorWithRed:0xea/255.0 green:0xb3/255.0 blue:0x7d/255.0 alpha:1.0].CGColor;
                            [self.aPlayer setImage:iconImage forKey:@"99" referenceLayer:iconLayer];
                        }
                        {
                            NSShadow *shadow = [NSShadow new];
                            shadow.shadowColor = [UIColor blackColor];
                            shadow.shadowOffset = CGSizeMake(0, 1);
                            NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"崔小姐不吃鱼 送了魔法奇缘"
                                                                                       attributes:@{
                                                                                                    NSForegroundColorAttributeName: [UIColor colorWithRed:0xff/255.0 green:0xe0/255.0 blue:0xa4/255.0 alpha:1.0],
                                                                                                    NSFontAttributeName: [UIFont boldSystemFontOfSize:30.0],
                                                                                                    NSShadowAttributeName: shadow,
                                                                                                    }];
                            [self.aPlayer setAttributedText:text forKey:@"banner"];
                        }
                        self.aPlayer.videoItem = videoItem;
                        [self.aPlayer startAnimation];
                    }
                } failureBlock:nil];
            }
        }
    }] resume];
    
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player {
//    NSLog(@"finished.");
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        SVGAParser *parser = [[SVGAParser alloc] init];
//        [parser parseWithURL:[NSURL URLWithString:@"http://uedfe.yypm.com/assets/svga-me/rose.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
//            if (videoItem != nil) {
//                self.aPlayer.videoItem = videoItem;
//                [self.aPlayer startAnimation];
//            }
//        } failureBlock:nil];
//    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.aPlayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 100);
}

- (SVGAPlayer *)aPlayer {
    if (_aPlayer == nil) {
        _aPlayer = [[SVGAPlayer alloc] init];
    }
    return _aPlayer;
}

@end

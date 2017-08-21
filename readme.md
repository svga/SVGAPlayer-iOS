# SVGAPlayer

## Version

### 1.1.4

改进 SVGAParser 在多任务处理时，存在的并发锁以及线程安全问题。

### 1.1.1

SVGAPlayer 的第 2 个版本，对应 SVGA-1.1.0 协议，支持矢量动画，向下兼容 SVGA-1.0.0 协议。

### 0.1.0

SVGAPlayer 的第 1 个版本，对应 SVGA-1.0.0 协议，支持位图（位移、旋转、拉伸、透明度）动画。

## SVGA Format

* SVGA 是一个私有的动画格式，由 YY UED 主导开发。
* SVGA 由 SVG 演进而成，与 SVG 不兼容。
* SVGA 可以在 iOS / Android / Web(PC/移动端) 实现高性能的动画播放。

@see http://code.yy.com/ued/SVGA-Format

## 安装

### CocoaPods

添加依赖到 Podfile
```
pod 'SVGAPlayer'
```

## 使用

### 初始化 Player

```
@interface XXX()
@property (nonatomic, strong) SVGAPlayer *aPlayer; // Init SVGAPlayer by yourself.
@end
```

### 初始化 Parser 并加载资源文件

```
SVGAParser *parser = [[SVGAParser alloc] init];
[parser parseWithURL:[NSURL URLWithString:@"http://uedfe.yypm.com/assets/svga-samples/angel.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
    if (videoItem != nil) {
        self.aPlayer.videoItem = videoItem;
        [self.aPlayer startAnimation];
    }
} failureBlock:nil];

```

## API

### Properties
* id<SVGAPlayerDelegate> delegate; - 各种回调
* SVGAVideoEntity *videoItem; - 动画实例
* int loops; - 循环次数，0 = 无限循环
* BOOL clearsAfterStop; - 是否在结束播放时清空画布。

### Methods

* (void)startAnimation; - 从 0 帧开始播放动画
* (void)pauseAnimation; - 在当前帧暂停动画
* (void)stopAnimation; - 停止播放动画，如果 clearsAfterStop == YES，则同时清空画布
* (void)clear; - 清空当前画布
* (void)stepToFrame:(NSInteger)frame andPlay:(BOOL)andPlay; - 跳到第 N 帧 (frame 0 = 第 1 帧)，然后 andPlay == YES 时播放动画
* (void)stepToPercentage:(CGFloat)percentage andPlay:(BOOL)andPlay; - 跳到动画对应百分比的帧，然后 andPlay == YES 时播放动画
* (void)setImage:(UIImage *)image forKey:(NSString *)aKey referenceLayer:(CALayer *)referenceLayer; - 设置动态图像
* (void)setAttributedText:(NSAttributedString *)attributedText forKey:(NSString *)aKey; - 设置动态文本
* (void)clearDynamicObjects; - 清空动态图像和文本

### SVGAPlayerDelegate

* @optional
* - (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player; - 动画播放结束后回调
* - (void)svgaPlayerDidAnimatedToFrame:(NSInteger)frame; - 动画播放到某一帖后回调
* - (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage; - 动画播放到某一进度百分比后回调

### 动态对象

可以通过以下方式，替换动画文件中的指定图像，以及动态添加富文本。

* 必须在 startAnimation 方法执行前进行配置

#### 动态图像

```
CALayer *iconLayer = [CALayer layer];
iconLayer.cornerRadius = 84.0;
iconLayer.masksToBounds = YES;
iconLayer.borderWidth = 4.0;
iconLayer.borderColor = [UIColor colorWithRed:0xea/255.0 green:0xb3/255.0 blue:0x7d/255.0 alpha:1.0].CGColor;
[self.aPlayer setImage:iconImage forKey:@"99" referenceLayer:iconLayer];
```

#### 动态文本

```
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
```

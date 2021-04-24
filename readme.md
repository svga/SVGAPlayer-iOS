# SVGAPlayer

[简体中文](./readme.zh.md)

## 支持本项目

1. 轻点 GitHub Star，让更多人看到该项目。

## 2.5.0 Released

This version add Support for matte layer and dynamic matte bitmap.<br>
Head on over to [Dynamic · Matte Layer](https://github.com/yyued/SVGAPlayer-iOS/wiki/Dynamic-%C2%B7-Matte-Layer)

This version add Support for audio step to frame & percentage.

## 2.3.5 Released

This version fixed SVGAPlayer `clearsAfterStop defaults too YES`, Please check your player when it doesn't need to be cleared.

This version fixed SVGAPlayer render issue on iOS 13.1, upgrade to this version ASAP.

## Introduce

SVGAPlayer is a light-weight animation renderer. You use [tools](http://svga.io/designer.html) to export `svga` file from `Adobe Animate CC` or `Adobe After Effects`, and then use SVGAPlayer to render animation on mobile application.

`SVGAPlayer-iOS` render animation natively via iOS CoreAnimation Framework, brings you a high-performance, low-cost animation experience.

If wonder more information, go to this [website](http://svga.io/).

## Usage

Here introduce `SVGAPlayer-iOS` usage. Wonder exporting usage? Click [here](http://svga.io/designer.html).

### Install Via CocoaPods

You want to add pod 'SVGAPlayer', '~> 2.3' similar to the following to your Podfile:

target 'MyApp' do
  pod 'SVGAPlayer', '~> 2.3'
end

Then run a `pod install` inside your terminal, or from CocoaPods.app.

### Locate files

SVGAPlayer could load svga file from application bundle or remote server.

### Using code

#### Create a `SVGAPlayer` instance.

```objectivec
SVGAPlayer *player = [[SVGAPlayer alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
[self.view addSubview:player]; // Add subview by yourself.
```

#### Create a `SVGAParser` instance, parse from bundle like this.
```objectivec
SVGAParser *parser = [[SVGAParser alloc] init];
[parser parseWithNamed:@"posche" inBundle:nil completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
    
} failureBlock:nil];
```

#### Create a `SVGAParser` instance, parse from remote server like this.

```objectivec
SVGAParser *parser = [[SVGAParser alloc] init];
[parser parseWithURL:[NSURL URLWithString:@"https://github.com/yyued/SVGA-Samples/blob/master/posche.svga?raw=true"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
    
} failureBlock:nil];
```

#### Set videoItem to `SVGAPlayer`, play it as you want.

```objectivec
[parser parseWithURL:[NSURL URLWithString:@"https://github.com/yyued/SVGA-Samples/blob/master/posche.svga?raw=true"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
    if (videoItem != nil) {
        player.videoItem = videoItem;
        [player startAnimation];
    }
} failureBlock:nil];
```

### Cache

`SVGAParser` use `NSURLSession` request remote data via network. You may use following ways to control cache.

#### Response Header

Server response SVGA files in Body, and response header either. response header has cache-control / etag / expired keys, all these keys telling NSURLSession how to handle cache.

#### Request NSData By Yourself

If you couldn't fix Server Response Header, You should build NSURLRequest with CachePolicy by yourself, and fetch NSData.

Deliver NSData to SVGAParser, as usual.

## Features

Here are many feature samples.

* [Replace an element with Bitmap.](https://github.com/yyued/SVGAPlayer-iOS/wiki/Dynamic-Image)
* [Add text above an element.](https://github.com/yyued/SVGAPlayer-iOS/wiki/Dynamic-Text)
* [Hides an element dynamicaly.](https://github.com/yyued/SVGAPlayer-iOS/wiki/Dynamic-Hidden)
* [Use a custom drawer for element.](https://github.com/yyued/SVGAPlayer-iOS/wiki/Dynamic-Drawer)

## APIs

Head on over to [https://github.com/yyued/SVGAPlayer-iOS/wiki/APIs](https://github.com/yyued/SVGAPlayer-iOS/wiki/APIs)

## CHANGELOG

Head on over to [CHANGELOG](./CHANGELOG.md)

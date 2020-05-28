# SVGAPlayer-iOS CHANGELOG (2020-05-28)

## [2.5.4](https://github.com/yyued/SVGAPlayer-iOS/tree/2.5.0-release)(2020-05-28)
### Bug Fixes
* Fix: audio could not play. ([cd6cca8](https://github.com/yyued/SVGAPlayer-iOS/commit/cd6cca8))

## [2.5.0](https://github.com/yyued/SVGAPlayer-iOS/tree/2.5.0-release)(2019-10-15)

### Features

* Add Support for matte layer and dynamic matte bitmap.
* Add Support for audio step to frame & percentage.

## [2.3.5](https://github.com/yyued/SVGAPlayer-iOS/compare/2.3.4...2.3.5) (2019-09-29)

### Bug Fixes

* Let clearsAfterStop defaults too YES. ([4932be5](https://github.com/yyued/SVGAPlayer-iOS/commit/4932be5))
* Add support for audio play in stepToFrame. ([873f8e4](https://github.com/yyued/SVGAPlayer-iOS/commit/873f8e4))
* Correct mp3 file match in proto image for iOS13. ([eb45964](https://github.com/yyued/SVGAPlayer-iOS/commit/eb45964))
* Correct ZIP file match when parse for iOS13. ([f3e204f](https://github.com/yyued/SVGAPlayer-iOS/commit/f3e204f))

## [2.3.4](https://github.com/yyued/SVGAPlayer-iOS/compare/2.3.3...2.3.4) (2019-08-02)

### Bug Fixes

* Correct file tag des hit target. ([0018e13](https://github.com/yyued/SVGAPlayer-iOS/commit/0018e13))
* Correct file tag des hit target. ([dc2e403](https://github.com/yyued/SVGAPlayer-iOS/commit/dc2e403))
* Fix static layer. ([ab1d4fc](https://github.com/yyued/SVGAPlayer-iOS/commit/ab1d4fc))
* Fix demo aspect scale. ([33ea6b3](https://github.com/yyued/SVGAPlayer-iOS/commit/33ea6b3))
* Fix key for svga 1.x format. ([ec43259](https://github.com/yyued/SVGAPlayer-iOS/commit/ec43259))
* Return when videoItem is nil in startAnimation. ([cb27f0f](https://github.com/yyued/SVGAPlayer-iOS/commit/cb27f0f))

### Features

* Add 2.x proto support for matte. ([527e76f](https://github.com/yyued/SVGAPlayer-iOS/commit/527e76f))
* Add slider for animation demo. ([fc9d7ef](https://github.com/yyued/SVGAPlayer-iOS/commit/fc9d7ef))
* Support bitmap matte layer. ([4c4e2b1](https://github.com/yyued/SVGAPlayer-iOS/commit/4c4e2b1))
* Support muti mask. ([188c1b3](https://github.com/yyued/SVGAPlayer-iOS/commit/188c1b3))
* Update 2.x proto support for matte. ([2b28845](https://github.com/yyued/SVGAPlayer-iOS/commit/2b28845))

### Bug Fixes

* Rollback SSZipArchive to 1.8.1 because of crash. ([2f9d94b](https://github.com/yyued/SVGAPlayer-iOS/commit/2f9d94b))

## [2.3.1](https://github.com/yyued/SVGAPlayer-iOS/compare/2.3.0...2.3.1) (2018-12-18)

### Bug Fixes

* Add enabledMemoryCache option to SVGAParser, disable memory cache to default. ([116a91f](https://github.com/yyued/SVGAPlayer-iOS/commit/116a91f))

## 2.3.0

### Features

*  Add audio support.

## 2.1.4 

### Bug Fixes

*  Add classtype asserts to avoid crash.

## 2.1.3

* Add SVGAImageView and SVGAVideoEntity to SVGA.h;
* Add URLRequest params to SVGAParser;

## 2.1.2

* Add dynamicHidden and dynamicDrawing.

## 2.1.1

### Bug Fixes
* Use CADisplayLink::invalid() replace removeFromRunloop.
improve: all Parser callback will perform on Main Thread.




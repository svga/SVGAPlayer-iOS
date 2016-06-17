
Pod::Spec.new do |s|

  s.name         = "SVGAPlayer"
  s.version      = "0.0.1"
  s.summary      = "SVGAPlayer 是一个高性能的大动画播放器，目前只支持 iOS，Android 正在开发中。"

  s.description  = <<-DESC
                   SVGA 是一个私有的动画格式，由 YY UED 主导开发。
                   SVGA 由 SVG 演进而成，与 SVG 不兼容。
                    SVGA 可以在 iOS / Android / Web(PC/移动端) 实现高性能的动画播放。
                   DESC

  s.homepage     = "http://code.yy.com/ued/SVGAPlayer"

  s.license      = "Private"
 
  s.author             = { "PonyCui" => "cuiminghui1@yy.com" }
  
  s.platform     = :ios, "7.0"

  s.source       = { :git => "http://code.yy.com/ued/SVGAPlayer.git", :tag => "0.0.1" }

  s.source_files  = "Source", "Source/*.{h,m}"

  s.requires_arc = true

end

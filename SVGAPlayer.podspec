
Pod::Spec.new do |s|
  s.name         = "SVGAPlayer"
  s.version      = "2.5.2"
  s.summary      = "SVGAPlayer 是一个高性能的动画播放器"
  s.description  = <<-DESC
                   SVGA 是一个私有的动画格式，由 YY UED 主导开发。
                   SVGA 由 SVG 演进而成，与 SVG 不兼容。
                   SVGA 可以在 iOS / Android / Web(PC/移动端) 实现高性能的动画播放。
                   DESC

  s.homepage     = "http://code.yy.com/ued/SVGAPlayer"
  s.license      = "Apache 2.0"
  s.author       = { "PonyCui" => "cuiminghui1@yy.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/yyued/SVGAPlayer-iOS.git", :tag => s.version }
  s.subspec 'Core' do |ss|
    ss.source_files  = "Source/*.{h,m}"
    ss.requires_arc = true
    ss.dependency 'SSZipArchive', '>= 1.8.1'
    ss.library = "z"
    ss.framework = "AVFoundation"
    ss.dependency 'SVGAPlayer/ProtoFiles'
  end
  s.subspec 'ProtoFiles' do |ss|
    ss.source_files  = "Source/pbobjc/*.{h,m}"
    ss.requires_arc = false
    ss.dependency 'Protobuf', '~> 3.4'
    ss.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1',
    }
  end  
end


Pod::Spec.new do |s|

  s.name         = 'SVGAPlayer'
  s.version      = '1.1.2'
  s.summary      = 'SVGAPlayer 是一个高性能的动画播放器'

  s.description  = <<-DESC
                   SVGA 是一个私有的动画格式，由 YY UED 主导开发。
                   SVGA 由 SVG 演进而成，与 SVG 不兼容。
                   SVGA 可以在 iOS / Android / Web(PC/移动端) 实现高性能的动画播放。
                   DESC

  s.homepage     = 'http://code.yy.com/ued/SVGAPlayer'

  s.license      = 'Private'
 
  s.author       = { 'PonyCui' => 'cuiminghui1@yy.com' }
  
  s.platform     = :ios, '7.0'

  s.source       = { :git => 'https://github.com/yyued/SVGAPlayer-iOS.git', :branch => s.version }

  s.requires_arc = true

  s.dependency 'SSZipArchive'

  s.default_subspec = 'Common'

  s.subspec 'Common' do |ss|
    ss.source_files  = 'Source', 'Source/*.{h,m}'
  end

  s.subspec 'React' do |ss|
    ss.dependency      'SVGAPlayer/Common'
    ss.source_files  = 'React', 'React/*.{h,m}'
  end

end

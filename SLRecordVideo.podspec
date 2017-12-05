Pod::Spec.new do |s|

s.name    = 'SLRecordVideo'

s.version  = '1.0.0'

s.ios.deployment_target = '8.0'

s.license  =  { :type => 'MIT', :file => 'LICENSE' }

s.summary  = '小视频录制'

s.homepage = 'https://github.com/wangshenglong/SLRecordVideo.git'

s.authors  = { "王胜龙" => "550122711@qq.com" }

s.source  = { :git => "https://github.com/wangshenglong/SLRecordVideo.git", :tag => "#{s.version}" }

s.description = '仿微信录制小视频'

s.source_files = 'SLRecordVideo/SLRecordVideo/**/*'

s.framework    = 'QuartzCore'

s.resources    = 'SLRecordVideo/Resource/**/*.{png,jpg}'

s.dependency "SCRecorder"
s.dependency "Masonry"

s.requires_arc = true

end
Pod::Spec.new do |s|
s.name             = 'adsRouter'
s.version          = '0.0.1'
s.summary          = 'iOS 路由模块'

s.description      = <<-DESC
TODO: iOS 路由模块
DESC

s.homepage         = 'https://github.com/aidongsheng/adsRouter'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'aidongsheng' => 'coding_ai@qq.com' }
s.source           = { :git => 'https://github.com/aidongsheng/adsRouter.git', :tag => s.version }

s.ios.deployment_target = '8.0'

s.source_files = 'adsRouter/Classes/**/*.{h,m}'


end

#
# Be sure to run `pod lib lint SDWebImageAPNGCoder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SDWebImageAPNGCoder'
  s.version          = '0.1.1'
  s.summary          = 'APNG decoder/encoder for SDWebImage coder plugin.'

  s.description      = <<-DESC
This is a simple SDWebImage coder plugin to support APNG image.
It also show how to build animated coder which use coder helper from SDWebImage
In 5.x, SDWebImage will replace this as built-in APNG coder instead
                       DESC

  s.homepage         = 'https://github.com/SDWebImage/SDWebImageAPNGCoder'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DreamPiggy' => 'lizhuoli1126@126.com' }
  s.source           = { :git => 'https://github.com/SDWebImage/SDWebImageAPNGCoder.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.default_subspec = 'Coder'

  s.subspec 'Coder' do |sub|
    sub.requires_arc = true
    sub.source_files = 'SDWebImageAPNGCoder/Classes/**/*.{h,m,swift}'
    sub.dependency 'SDWebImage', '~> 5.0'
    sub.dependency 'SDWebImageAPNGCoder/apng'
  end

  s.subspec 'apng' do |sub|
    sub.requires_arc = false
    sub.libraries = "z"
    sub.source_files = 'apng/**/*.{h,c}'
    sub.public_header_files = 'apng/png.h', 'apng/pngconf.h', 'apng/pnglibconf.h'
    sub.compiler_flags = '-DHAVE_CONFIG_H'
  end
end

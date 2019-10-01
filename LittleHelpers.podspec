#
# Be sure to run `pod lib lint LittleHelpers.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LittleHelpers'
  s.version          = '0.1.1'
  s.summary          = 'LittleHelpers is a collection of classes and protocols that I often use.'
  s.homepage         = 'https://github.com/themisterholliday/LittleHelpers'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'themisterholliday' => 'hello@craigholliday.net' }
  s.source           = { :git => 'https://github.com/themisterholliday/LittleHelpers.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/TheMrHolliday'

  s.ios.deployment_target = '10.3'
  s.swift_version = '5.0'

  s.source_files = 'LittleHelpers/Classes/**/*'
end

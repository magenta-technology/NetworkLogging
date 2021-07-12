#
# Be sure to run `pod lib lint NetworkLogging.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NetworkLogging'
  s.version          = '0.0.5'
  s.summary          = 'NetworkLogging helps you to analyze network traffic.'

  s.description      = <<-DESC
NetworkLogging helps you to analyze network traffic. By default, it collects only url traffic. For other, you can add custom functions.
                       DESC

  s.homepage         = 'https://github.com/magenta-technology/NetworkLogging'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pavel Volkhin' => 'pavel.volhin@magenta-technology.com' }
  s.source           = { :git => 'https://github.com/magenta-technology/NetworkLogging.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'NetworkLogging/Classes/**/*.{m,h,swift}'
  s.swift_versions = ['4.2']
  
  s.resources = "NetworkLogging/**/*.xcdatamodeld"
end

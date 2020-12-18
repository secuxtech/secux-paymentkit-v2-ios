#
# Be sure to run `pod lib lint secux-paymentkit-v2.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'secux-paymentkit-v2'
  s.version          = '2.1.18'
  s.summary          = 'iOS Lib for SecuX P22/P20'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
iOS Lib for SecuX Payment device P22 and P20
                       DESC

  s.homepage         = 'https://www.secuxtech.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'maochuns' => 'maochuns.sun@gmail.com' }
  s.source           = { :git => 'https://github.com/secuxtech/secux-paymentkit-v2-ios', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.platform              = :ios, "12.0"

  s.source_files = 'secux-paymentkit-v2/Classes/**/*'
  
  # s.resource_bundles = {
  #   'secux-paymentkit-v2' => ['secux-paymentkit-v2/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  
  s.static_framework = true
  s.dependency 'secux-paymentdevicekit'
  
end

#
# Be sure to run `pod lib lint secux-paymentkit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'secux-paymentkit-v2'
  s.version          = '1.0.0'
  s.summary          = 'secux-paymentkit-v2 for SecuX P20/P22'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SecuX paymentkit for P22 v2
                       DESC

  s.homepage         = 'https://www.secuxtech.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SecuX' => 'maochuns.sun@gmail.com' }
  s.source           = { :git => 'https://github.com/secuxtech/secux-paymentkit-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'secux-paymentkit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'secux-paymentkit' => ['secux-paymentkit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.static_framework = true
  #s.dependency 'SPManager', '~> 0.0.2'
  s.dependency 'secux-paymentdevicekit', '~> 1.0.2'
end

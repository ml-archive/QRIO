#
# Be sure to run `pod lib lint TuvaUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QRIO'
  s.version          = '1.0.0'
  s.summary          = 'Lightweight framework for QR scanning and generation
'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Lightweight framework for QR scanning and generation
  ## 💻 Usage
  **Creating a QR Code:**

  It's as easy as

  ~~~swift
  let image = UIImage.QRImageFrom(string: "Hello World!")
  ~~~


                       DESC

  s.homepage         = 'https://github.com/nicktrienensfuzz/qrio'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nick Trienens' => 'nick@fuzz.pro' }
  s.source           = { :git => 'https://github.com/com:nicktrienensfuzz/qrio.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.2'

  s.default_subspecs = "Core"

  s.subspec 'Core' do |core|
      core.source_files = [ 'QRIO/QRIO.swift']
  end


end

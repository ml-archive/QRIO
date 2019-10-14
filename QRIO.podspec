# coding: utf-8

Pod::Spec.new do |spec|

  spec.name         = "QRIO"
  spec.version      = "3.0.0"
  spec.summary      = "Lightweight framework for QR scanning and generation"
  spec.homepage     = "https://github.com/nodes-ios/QRIO"

  spec.author       = { "Nodes Agency - iOS" => "ios@nodes.dk" }
  spec.license      = { :type => 'MIT', :file => './LICENSE' }

  spec.platform     = :ios
  spec.source       = { :git => "https://github.com/nodes-ios/QRIO.git", :tag => "#{spec.version}" }

  spec.ios.deployment_target = '9'
  spec.ios.vendored_frameworks = 'QRIO.framework'

  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  spec.subspec 'QRIO' do |subspec|
    subspec.ios.source_files = 'QRIO/**/*.swift'
  end
end

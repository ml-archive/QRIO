
Pod::Spec.new do |spec|
  spec.name         = "QRIO"
  spec.version      = "3.0.1"

  spec.summary      = "Lightweight framework for QR scanning and generation."
  spec.homepage     = "https://github.com/nodes-ios/QRIO"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Nodes Agency - iOS" => "ios@nodes.dk" }

  spec.platform     = :ios, "9.0"
  spec.swift_version = '5.0'
  spec.source       = { :git => "https://github.com/nodes-ios/QRIO.git", :tag => "#{spec.version}" }

  spec.subspec 'QRIO' do |subspec|
    subspec.ios.source_files = 'QRIO/**/*.swift'
  end

end

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNBluetoothEscposPrinter"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.author       = 'ducnt3'
  s.homepage     = 'https://github.com/ducnt3/react-native-bluetooth-printer'
  s.license      = package["license"]
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/ducnt3/react-native-bluetooth-printer", :tag => "#{s.version}" }
  s.source_files  = "ios/**/*.{h,m}"
  s.dependency "React"
end

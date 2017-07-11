source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target 'FareCompareV2' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'UberRides', :git => 'https://github.com/uber/rides-ios-sdk.git', :branch => 'swift-3-dev'
  pod 'Alamofire', '~> 4.4'

  # Pods for FareCompareV2

  target 'FareCompareV2Tests' do
    inherit! :search_paths
    # Pods for testing
    pod 'UberRides', :git => 'https://github.com/uber/rides-ios-sdk.git', :branch => 'swift-3-dev'
    pod 'Alamofire', '~> 4.4'
    
  end

  target 'FareCompareV2UITests' do
    inherit! :search_paths
    # Pods for testing
    pod 'UberRides', :git => 'https://github.com/uber/rides-ios-sdk.git', :branch => 'swift-3-dev'
    pod 'Alamofire', '~> 4.4'
    
  end

end

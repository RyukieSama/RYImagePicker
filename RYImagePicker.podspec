Pod::Spec.new do |s|
  s.name         = "RYImagePicker"
  s.summary      = "ImagePicker of Ryukie’s"
  s.version      = "0.0.2"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Ryukie" => "ryukie.sama@gmail.com" }
  s.homepage     = "https://github.com/RyukieSama/RYImagePicker.git"
  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.source       = { :git => 'https://github.com/RyukieSama/RYImagePicker.git', :tag => s.version}
  s.resource  = "RYPhotosPickerManager.bundle"
  s.requires_arc = true
  s.source_files = 'RYImagePicker/**/*.{h,m}'

  s.libraries = 'z', 'sqlite3'
  s.dependency "Masonry", "~> 1.0.2"

end

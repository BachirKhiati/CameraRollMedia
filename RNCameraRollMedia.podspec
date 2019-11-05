require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name           = 'RNCameraRollMedia'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = 'https://github.com/BachirKhiati/CameraRollMedia'
  s.source       = { :git => "https://github.com/BachirKhiati/CameraRollMedia.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.0"

  s.subspec "RNCameraRollMedia" do |ss|
    ss.source_files  = "ios/*.{h,m,swift}"
    s.static_framework = true
  end

  s.dependency "React"

  s.default_subspec = "RNCameraRollMedia"
end

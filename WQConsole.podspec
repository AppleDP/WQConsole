Pod::Spec.new do |s|
  s.name         = "WQConsole"
  s.version      = "1.0.0"
  s.summary      = "在App运行页面输出日志"
  s.description  = <<-DESC
  在App运行页面显示Xcode控制台输出的日志
                   DESC

  s.homepage     = "https://github.com/AppleDP/WQConsole"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "AppleDP" => "SWQAppleDP@163.com" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/AppleDP/WQConsole.git", :tag => s.version }
  s.source_files  = "WQConsole/**/WQConsole/*.{h,m}"
end

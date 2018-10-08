#
#  Be sure to run `pod spec lint TSRouter.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "TSRouter"
  s.version      = "1.0.7"
  s.summary      = "this is app router"

  s.description  = <<-DESC
                  这是一个路由，支持url跳转页面; url定义：URLScheme://moduleName.transitionStyle/pageName?key=value....#isNeedLogin
                   DESC
  s.platform     = :ios, "8.0"
  s.homepage     = "https://www.jianshu.com/u/8a7102c0b777"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "yuchenH" => "huangyuchen@caiqr.com" }
 
  s.source       = { :git => "http://gitlab.caiqr.com/ios_module/TSRouter.git", :tag => s.version }

  s.source_files  = "TSRouter/code"

  s.framework  = "UIKit","Foundation"

  s.swift_version = '4.0'

  s.requires_arc = true
end


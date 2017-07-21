#
# Be sure to run `pod lib lint SHMultipleSelect.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SHMultipleSelect"
  s.version          = "0.2.3"
  s.summary          = "An easy-to-use multiple selection view."
  s.description      = <<-DESC
                       An easy-to-use multiple selection view for iOS *+.
                       DESC
  s.homepage         = "https://github.com/Shamsiddin/SHMultipleSelect"
  s.license          = 'MIT'
  s.author           = { "Shamsiddin" => "shamsiddin.saidov@gmail.com" }
  s.source           = { :git => "https://github.com/Shamsiddin/SHMultipleSelect.git", :tag => s.version.to_s }

  s.platform         = :ios, '8.0'
  s.requires_arc     = true

  s.source_files = 'Pod/Classes/*.{h,m}'
end

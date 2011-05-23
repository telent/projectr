require 'bundler/version'
 
Gem::Specification.new do |s|
  s.name        = "projectr"
  s.version     = "0.01"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Barlow"]
  s.email       = ["dan@telent.net"]
  s.summary     = "A declarative syntax to describe the files comprising your app"
  s.description = "ProjectR is a small DSL for describing the source files comprising an application and the dependencies and load order constraints between them, enabling the development of tools that can act on these files in various ways.  Lisp users may know the concept as DEFSYSTEM."
 
  s.required_rubygems_version = ">= 1.3.6"
#  s.rubyforge_project         = ""
 
  s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{bin,lib}/**/*") + %w(README.md)
#  s.executables  = []
  s.require_path = 'lib'
end

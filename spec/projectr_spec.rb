require 'projectr'
require 'fileutils'

load "fixture/test.project.rb"

describe Projectr::Project do
  p=Projectr::Project[:test] 
  it "contains the specified files in the specified order" do
    p.source_files.map(&:name).should ==
      (["example/file1.rb","example/file2.rb","example/subdir/subdir_file.rb"].
       map{|x| File.expand_path(x,File.join(File.dirname(__FILE__),"fixture")) })
  end
  it "finds the project and loads it" do
    p1=Projectr::Project[:test]
    p2=Projectr::Project.find :test
    p1.should == p2
    p1.load!
  end
end

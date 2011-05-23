require 'projectr'
require 'fileutils'

load "fixture/test.project.rb"

describe Projectr::Project do
  p=Projectr::Project[:test] 
  it "contains the specified files in the specified order" do
    p.source_files.map(&:name).should ==
      (["example/file1.rb","example/file2.rb","example/file3.rb",
        "example/subdir/subdir_file.rb"].
       map{|x| File.expand_path(x,File.join(File.dirname(__FILE__),"fixture")) })
  end
  it "finds the project and loads it" do
    p1=Projectr::Project[:test]
    p2=Projectr::Project.find :test
    p1.should == p2
    p1.load!
  end
  it "reloads changed files and files depending on them" do
    p1=Projectr::Project[:test]
    p1.load!
    ($file1 && $file2 && $file3).should be true
    $file1=nil;    $file2=nil;    $file3=nil
    f=File.expand_path("example/file1.rb",File.join(File.dirname(__FILE__),"fixture"))
    FileUtils.touch f
    p1.load!
    $file2.should be nil
    ($file1 && $file3).should be true
  end
  it "detects filesystem changes" do
    require 'projectr/watch_changes'
    w=p.watch_changes
    w.changed_files.should be_empty
    require 'fileutils'
    # XXX pity the poor sod who needs to build this using a read-only
    # source tree.
    FileUtils.touch(p.source_files[1].name)
    sleep 0.1
    w.changed_files.should include p.source_files[1].name

    # check the io handle thingy works
    start=Time.now
    Thread.new do
      sleep 2
      FileUtils.touch(p.source_files[1].name)
    end
    IO.select([w.to_io],[],[],15)
    elapsed=Time.now-start
    elapsed.should be > 1
    elapsed.should be < 14
  end
end

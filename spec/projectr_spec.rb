require 'projectr'

Projectr::Project.new :test do
  # directories may be named by symbols or strings
  directory :example do
    #as may files
    file "file1"
    file :file2
    directory "subdir" do 
      file :subdir_file
    end
  end
end

describe Projectr::Project do
  p=Projectr::Project[:test] 
  it "should contain the specified files in the specified order" do
    p.source_files.map(&:name).should ==
      (["example/file1.rb","example/file2.rb","example/subdir/subdir_file.rb"].
       map{|x| File.expand_path(x,File.dirname(__FILE__)) })
  end
end

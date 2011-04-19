
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

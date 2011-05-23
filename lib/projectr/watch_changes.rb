# extend the project with a #watch_changes method to notify us 
# when the files comprising it change

if RUBY_PLATFORM.match(/linux/) then
  require "rb-inotify"

  class Projectr::FileChangeWatcher < INotify::Notifier
    
    def initialize(files)
      super()
      @files=files
      @files.map{|x| File.dirname(x.name) }.uniq.each do |dir|
        self.watch(dir,:close_write,:attrib)
      end
    end

    # #to_io is required to be implemented; we inherit it from superclass

    # return a list of changed files. 
    def changed_files
      a=[self.to_io]
      # don't block
      changes=[]
      if IO.select(a,a,a,0) then
        self.read_events.each do |e| 
          if @files.map(&:name).member?(e.absolute_name) then
            changes << e.absolute_name 
          end
        end
      end
      changes
    end
  end
end

Projectr.const_get(:FileChangeWatcher) or
  raise "Projectr::FileChangeWatcher not implemented for this platform"

class Projectr::Project
  # Returns some object that responds to #to_io and to #changed_files.
  # #to_io is an IO object that becomes ready for io when one or more
  # of the project source files have been changed, and so can be 
  # checked as part of an application event loop.  #changed_files
  # is an array of the files in which changes have been detected
  # since it was last called.
  def watch_changes(&blk)
    Projectr::FileChangeWatcher.new(@source_files,&blk)
  end
end

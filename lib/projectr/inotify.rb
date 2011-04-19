# Extend the Project class to watch for project file changes
require 'rb-inotify'

module Projectr::Inotify
  # As the Project is the thing with responsibility for knowing which
  # files comprise the application/library, it should also be the
  # thing that can tell us when one of them has changed.  But to give
  # us unsolicited updates on file state changes it needs some kind of
  # thread of execution, and this probably conflicts with whatever
  # event loop the application itself is using.  So rather than
  # creating an event loop ourselves, we create an INotify::Inotifier
  # object which the caller can start a thread for or incorporate into
  # their EM loop or deal with however else they wish

  # Create an INotify::Inotifier object to watch the files in this
  # project, calling the provided block when any changes.  The block
  # is called with arguments (project,pathname)
  # 
  # This is only activated once INotify::Inotifier{#process,#run} is
  # called.  Consult rb-inotify docs for more information

  def watch_files(&blk)
    i=::INotify::Notifier.new
    @source_files.map{|x| File.dirname(x.name) }.uniq.each do |dir|
      i.watch(dir,:close_write,:attrib) do |e|
        warn [:inotify,e.absolute_name]
        if @source_files.map(&:name).member?(e.absolute_name) then
          warn [:inotify, "got one!"]
          if blk then yield self,e.absolute_name end
        end
      end
    end
    i
  end
end

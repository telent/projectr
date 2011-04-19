
class Projectr::Project
  @@systems ||={}
  class << self
    def find(name)
      if name.respond_to?(:load!) then name else @@systems[name] end
    end
    alias [] find
  end
  class Dep
    attr_accessor :name,:last_loaded
    def initialize(name) ; @name=name;end
  end

  attr_accessor :source_files, :verbose

  def initialize(name,file=nil,&blk)
    @last_changed=Hash.new {|h,k| h[k]=Time.at(0) }
    @source_files=[]
    @name=name
    @sysdef_file=file || Kernel.caller(1)[0].split(/:/)[0]
    @prefix=[File.dirname(@sysdef_file)]
    @sysdef_mtime=File.stat(@sysdef_file).mtime
    self.instance_eval &blk
    @@systems[name]=self
  end
  def directory(dir)
    begin
      @prefix.push(dir.to_s)
      yield
    ensure
      @prefix.pop
    end
  end
  def file(name)
    @source_files << Dep.new(File.join(*@prefix,name.to_s+".rb"))
  end

  def load!(args={})
    force=args[:force]
    verbose=args[:verbose]
    mt= File.stat(@sysdef_file).mtime
    if mt > @sysdef_mtime
      @sysdef_mtime = mt
      load @sysdef_file
      # +self+ is now stale, so call the new system definition object's
      # method instead
      return Defsys[@name].load!(force)
    end
    @source_files.each do |f|
      name=f.name
      changed=File.stat(name).mtime
      if force || (changed>@last_changed[name]) then
        verbose and warn "Loading #{name}"
        Kernel.load(name)
        @last_changed[name]=changed
      end
    end
    true
  end
  
end



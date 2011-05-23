
class Projectr::Project
  @@systems ||={}
  class << self
    def find(name)
      if name.respond_to?(:load!) then name else @@systems[name] end
    end
    alias [] find
  end
  class Dep
    attr_accessor :name,:last_loaded,:needed_by
    def initialize(name,options) 
      @needed_by=[]
      @name=name; @options=options
    end
  end

  def find(name)
    @source_files.find {|d| d.name == File.join(*@prefix,name.to_s+".rb") }
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
  def file(name,opts={})
    d=Dep.new(File.join(*@prefix,name.to_s+".rb"),
              opts)
    n=opts[:needs]
    n and n.each do |needed|
      d1=find(needed)
      if d1 then
        d1.needed_by << d
      else
        raise "Can't find component #{needed}, needed by #{d.name}"
      end
    end
    @source_files << d
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
      return self.class[@name].load!(force)
    end
    changes=[]
    @source_files.each do |f|
      name=f.name
      changed=File.stat(name).mtime
      if force || (changed>@last_changed[name]) then
        verbose and warn "Loading #{name}"
        changes << name
        f.needed_by.each do |d|
          # for all the files that depend on this, force their
          # last-change time to 0 so that they will be marked as needing
          # reload when it's their turn to be checked
          @last_changed.delete(d.name)
        end
        @last_changed[name]=changed
      end
    end
    changes.each do |f| Kernel.load(f) end
    true
  end
end

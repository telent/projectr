# Project {for,in} R{uby}

A declarative language ("DSL") to describe the source files comprising
your application or library and the relationships/dependencies between
them.  Projectr is intended for use as a canonical list (manifest) of
the project contents that can be interrogated for the purposes of e.g.

* loading it at startup time

* reloading it (e.g. in a web server or in irb) when source files
  change.  Comes with inotify support on Linux platforms, patches for
  other platforms with file change notifications welcome

* generating a file list for Gem or other package creation 

* file list ditto for rdoc or similar

* probably other stuff I haven't thought of yet

Here's an example:

    Projectr::Project.new :test do
      # directories may be named by symbols or strings
      directory :example do
        #as may files
        file "file1"
        file :file2, :needs=>["file1"]
        directory "subdir" do 
          file :subdir_file
        end
      end
    end

    h=Projectr::Project[:test]
    h.load!
    # and again
    h.load!   # nothing happens this time
    # touch example/file1.rb
    h.load!   # loads only the changed file

When you call load! the first time in any session, files are loaded in
the order they are listed, and their last-changed-on-disk times are
stored.  When you call it a second or subsequent time, each file's
last-change time will be compared to the time it was previously
loaded, and it will be skipped unless (a) it has changed, or (b)
its `:needs` clause specifies one or more files that have changed.

Common Lisp hackers will know what I mean when I say "it's Defsystem in 
Ruby".  They will then shortly be disappointed when they realise just
how little it actually does (almost nothing whatsoever) compared to the
system definition tools they know and are used to.  Just warning you,
guys.

The syntax is stating to solidify, but not yet set in stone.  There is
an example system in spec/fixture/example which also serves as a text
fixture.

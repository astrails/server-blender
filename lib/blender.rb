#!/usr/bin/ruby -rrubygems

module Blender
  FILE = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
  ROOT = File.expand_path(File.join(File.dirname(FILE), "/.."))

  def path(*args)
    File.join(File.join(ROOT, *args))
  end
  
  def content(*args)
    File.read(path(*args))
  end
  
end



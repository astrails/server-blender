module Blender::Manifest::Init
  def self.included(base)
    base.class_eval do
      recipe :create_blender_directories
    end
  end

  # create blender directories
  # @return dependency ref for the direcotires creation
  def create_blender_directories
    @create_blender_directories ||=
      begin
        dep = directory "/var/lib/blender", :mode => 0700
        dep = directory "/var/lib/blender/logs", :require => dep
        dep = directory "/var/lib/blender/tmp", :require => dep
      end
  end

  # @return dependency for blender directories
  def builder_deps
    create_blender_directories
  end
end

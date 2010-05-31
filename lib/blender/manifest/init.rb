module Blender::Manifest::Init
  def self.included(base)
    base.class_eval do
      recipe :create_blender_directories
    end
  end

  # create blender directories
  def create_blender_directories
    file "/var/lib/blender",
      :ensure => :directory,
      :mode => 0700,
      :owner => "root"
    file "/var/lib/blender/logs",
      :ensure => :directory,
      :owner => "root",
      :require => file("/var/lib/blender")
    file "/var/lib/blender/tmp",
      :ensure => :directory,
      :owner => "root",
      :require => file("/var/lib/blender")
    file "/var/lib/blender/install-stamp",
      :alias => "blender-installed",
      :ensure => :directory,
      :owner => "root",
      :require => file("/var/lib/blender")
  end

  # @return dependency for blender directories
  def builder_deps
    file("blender-installed")
  end
end

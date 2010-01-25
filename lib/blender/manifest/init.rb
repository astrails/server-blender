module Blender
  module Manifest
    module Init
      
      def self.included(base)
        base.class_eval do
          recipe :init_blender
        end
      end

      def init_blender
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

      def builder_deps
        file("blender-installed")
      end

    end
  end
end

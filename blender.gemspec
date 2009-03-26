Gem::Specification.new do |s|
  s.name     = "blender"
  s.version  = "0.0.1"
  s.date     = "2009-03-27"
  s.summary  = "Server provisioning and maintenance tool"
  s.email    = "we@astrails.com"
  s.homepage = "http://github.com/astrails/servershape-core"
  s.description = <<-END
Provision and configure servers (currently supporting EC2).
Describe server configuration using clean ruby DSL (provided by shadow_puppet)
END
  s.has_rdoc = false
  s.authors  = ["Astrails Ltd."]
  s.platform = Gem::Platform::RUBY
  s.files    = files = %w(
    Rakefile
    bin/blender
    blender.gemspec

    files/apt/ubuntu-intrepid-ec2-sources.list
    files/apt/ubuntu-intrepid-sources.list
    files/bootstrap.sh

    lib/blender.rb
    lib/blender/cli/init.rb
    lib/blender/cli/mix.rb

  )
  s.executables = files.grep(/^bin/).map {|x| x.gsub(/^bin\//, "")}

  s.test_files = []
  s.add_dependency("shadow_puppet")
  
  s.post_install_message = <<-END
===================================================================
Run "blender init HOSTNAME" to bootstrap blender on a remote host
Run "blender mix RECIPES_DIR HOST" to build host configuration.
===================================================================
END
end


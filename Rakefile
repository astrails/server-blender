require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "server-blender"
    gem.summary = %Q{Server provisioning and configuration management tool}
    gem.description = <<-DESC
Boostrap and manage servers with shadow\_puppet

Server Blender tries to be a fairly minimal wrapper around shadow\_puppet
http://github.com/railsmachine/shadow\_puppet

shadow\_puppet is a Ruby interface to Puppet's manifests.
http://reductivelabs.com/products/puppet/
    DESC
    gem.email = "vitaly@astrails.com"
    gem.homepage = "http://astrails.com/opensource/server-blender"
    gem.authors = ["Vitaly Kushner"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

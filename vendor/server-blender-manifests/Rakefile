require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "server-blender-manifest"
    gem.summary = %Q{server-side root manifest implementation for server-blender}
    gem.description = <<-DESC
This gem is part of the server-blender family (http://astrails.com/opensource/server-blender)
It contains server-side root manifest implementation for blender recipes. See server-blender for more information.
    DESC
    gem.email = "vitaly@astrails.com"
    gem.homepage = "http://astrails.com/opensource/server-blender"
    gem.authors = ["Vitaly Kushner"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
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

# documentaion is included in the parent server-blender gem

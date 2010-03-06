require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "blender"
    gem.summary = %Q{Server provisioning and maintenance tool}
    gem.email = "vitaly@astrails.com"
    gem.homepage = "http://astrails.com/blender"
    gem.authors = ["Vitaly Kushner"]
    gem.add_development_dependency "yard", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

task :default => :yard

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

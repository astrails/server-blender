# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{blender}
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vitaly Kushner"]
  s.date = %q{2010-03-10}
  s.default_executable = %q{blender}
  s.email = %q{vitaly@astrails.com}
  s.executables = ["blender"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "PLAN",
     "README.markdown",
     "Rakefile",
     "VERSION.yml",
     "bin/blender",
     "blender.gemspec",
     "files/bootstrap.sh",
     "lib/blender.rb",
     "lib/blender/cli/init.rb",
     "lib/blender/cli/mix.rb",
     "lib/blender/cli/start.rb",
     "lib/blender/manifest/init.rb",
     "lib/blender/manifest/mixer.rb",
     "lib/blender/manifest/nodes.rb",
     "lib/blender/manifest/roles.rb",
     "lib/blender/manifest/root.rb"
  ]
  s.homepage = %q{http://astrails.com/blender}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Server provisioning and maintenance tool}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<yard>, [">= 0"])
  end
end


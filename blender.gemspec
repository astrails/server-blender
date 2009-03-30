# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{blender}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vitaly Kushner"]
  s.date = %q{2009-03-30}
  s.default_executable = %q{blender}
  s.email = %q{vitaly@astrails.com}
  s.executables = ["blender"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["README.rdoc", "VERSION.yml", "bin/blender", "lib/blender", "lib/blender/cli", "lib/blender/cli/init.rb", "lib/blender/cli/mix.rb", "lib/blender/cli/provision.rb", "lib/blender/vlad.rb", "lib/blender.rb", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/astrails/blender}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Server provisioning and maintenance tool}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

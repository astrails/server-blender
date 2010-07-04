require 'spec_helper'
require 'blender/cli/mix'

describe Blender::Cli::Mix do
  before(:each) do
    @mix = Blender::Cli::Mix.new []
  end

  describe :parse_options do
    it "should throw usage on --help" do
      proc {
        @mix.parse_options(%w/-h/)
      }.should raise_error(RuntimeError, <<-USAGE)
Usage: blender mix [OPTIONS] [DIR] HOST
Options:
    -r, --recipe RECIPE              if RECIPE is not specified blender will first look for <directory_name>.rb and then for blender-recipe.rb
    -N, --node NODE                  force NODE as the current nodename
    -R, --roles ROLES                comma delimited list of roles that should execute

Common options:
    -h, --help                       Show this message

Notes:
    "." used if DIR not specified
      USAGE

      proc {
        @mix.parse_options(%w/--help/)
      }.should raise_error(RuntimeError, /\AUsage:/)
    end

    it "should throw usage on missing parameters" do
      proc {
        @mix.parse_options(%w//)
      }.should raise_error(RuntimeError, /\AUsage:/)
    end

    it "should throw usage on extra args" do
      proc {
        @mix.parse_options(%w/aaa bbb ccc/)
      }.should raise_error(RuntimeError, /\Aunexpected: ccc\nUsage:/)
    end

    it "should only arg as host and dir as ." do
        opts = @mix.parse_options(%w/aaa/)
        opts[:host].should == "aaa"
        opts[:dir].should == "."
    end

    it "should throw usage if dir doesn't exist" do
      proc {
        @mix.parse_options(%w/aaa bbb/)
      }.should raise_error(RuntimeError, /\Aaaa is not a directory/)
    end

    it "should parse host and dir args" do
      opts = @mix.parse_options(%w/spec some-host/)
      opts[:dir].should == "spec"
      opts[:host].should == "some-host"
    end

    it "should parse -N" do
      @mix.parse_options(%w/-N node1 host/)[:node].should == "node1"
    end

    it "should parse -R" do
      @mix.parse_options(%w/-R role1 host/)[:roles].should == "role1"
    end

    it "should parse -r" do
      @mix.parse_options(%w/-r foo host/)[:recipe].should == "foo"
    end
  end

  describe :find_recipe do
    it "should return recipe if exists" do
      mock(File).file?("path/to/foo/bar") {true}
      @mix.find_recipe(:dir => "path/to/foo", :recipe => "bar").should == "bar"
    end

    it "should return recipe.rb if exists" do
      mock(File).file?("path/to/foo/bar") {false}
      mock(File).file?("path/to/foo/bar.rb") {true}
      @mix.find_recipe(:dir => "path/to/foo", :recipe => "bar").should == "bar.rb"
    end

    it "should return dirname.rb if exists" do
      mock(File).file?("path/to/foo/foo.rb") {true}
      @mix.find_recipe(:dir => "path/to/foo").should == "foo.rb"
    end

    it "should return blender-recipe.rb if exists" do
      mock(File).file?("path/to/foo/foo.rb") {false}
      mock(File).file?("path/to/foo/blender-recipe.rb") {true}
      @mix.find_recipe(:dir => "path/to/foo").should == "blender-recipe.rb"
    end

    it "should return raise error if no recipe found" do
      proc {
        @mix.find_recipe(:dir => "path/to/foo", :usage => "Usage:")
      }.should raise_error(
        RuntimeError,
        /recipe not found \(looking for foo.rb blender-recipe.rb\)\nUsage:/)
    end

    it "should NOT look for directory.rb if given recipe" do
      mock(File).file?("path/to/foo/bar") {false}
      mock(File).file?("path/to/foo/bar.rb") {false}
      dont_allow(File).file?("path/to/foo/foo.rb") {false}
      dont_allow(File).file?("path/to/foo/blender-recipe.rb") {false}
      proc {
        @mix.find_recipe(:dir => "path/to/foo", :recipe => "bar")
      }.should raise_error(RuntimeError, /recipe not found \(looking for bar bar.rb\)/)
    end

  end

  describe :run_recipe do
    it "should raise if init.sh fails" do
      mock(File).expand_path("files/init.sh", Blender::ROOT) {"path/to/files/init.sh"}
      mock(@mix).run("cat path/to/files/init.sh | ssh host /bin/bash -l") {false}
      proc {
        @mix.run_recipe "foo.rb", :host => "host"
      }.should raise_error(RuntimeError, "failed init.sh")
    end

    it "should raise if rsync fails" do
      stub(File).expand_path("files/init.sh", Blender::ROOT) {"path/to/files/init.sh"}
      stub(@mix).run("cat path/to/files/init.sh | ssh host /bin/bash -l") {true}
      mock(@mix).run("rsync -qazP --delete --exclude '.*' foo/ host:/var/lib/blender/recipes") {false}
      proc {
        @mix.run_recipe "foo.rb", :host => "host", :dir => "foo"
      }.should raise_error(RuntimeError, "failed rsync")
    end

    it "should raise if mix fails" do
      stub(File).expand_path("files/init.sh", Blender::ROOT) {"path/to/files/init.sh"}
      stub(@mix).run("cat path/to/files/init.sh | ssh host /bin/bash -l") {true}
      stub(@mix).run("rsync -qazP --delete --exclude '.*' foo/ host:/var/lib/blender/recipes") {true}
      mock(File).expand_path("files/mix.sh", Blender::ROOT) {"path/to/files/mix.sh"}
      mock(@mix).run("cat path/to/files/mix.sh | ssh host RECIPE=foo.rb NODE=zoo ROLES=a,b /bin/bash -l") {false}
      proc {
        @mix.run_recipe "foo.rb", :host => "host", :dir => "foo", :roles => "a,b", :node => "zoo"
      }.should raise_error(RuntimeError, "failed mix.sh")
    end

    it "should run init, rsync and mix and return true" do
      mock(File).expand_path("files/init.sh", Blender::ROOT) {"path/to/files/init.sh"}
      mock(@mix).run("cat path/to/files/init.sh | ssh host /bin/bash -l") {true}
      mock(@mix).run("rsync -qazP --delete --exclude '.*' foo/ host:/var/lib/blender/recipes") {true}
      mock(File).expand_path("files/mix.sh", Blender::ROOT) {"path/to/files/mix.sh"}
      mock(@mix).run("cat path/to/files/mix.sh | ssh host RECIPE=foo.rb NODE=zoo ROLES=a,b /bin/bash -l") {true}
      @mix.run_recipe("foo.rb", :host => "host", :dir => "foo", :roles => "a,b", :node => "zoo").should == true
    end
  end

end

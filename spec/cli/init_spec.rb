require 'spec_helper'
require 'blender/cli/init'

describe Blender::Cli::Init do
  before(:each) do
    @init = Blender::Cli::Init.new []
  end

  describe :parse_options do
    it "should throw usage on --help" do
      proc {
        @init.parse_options(%w/-h/)
      }.should raise_error(RuntimeError, /\AUsage:/)

      proc {
        @init.parse_options(%w/--help/)
      }.should raise_error(RuntimeError, /\AUsage:/)
    end

    it "should throw usage on missing parameters" do
      proc {
        @init.parse_options(%w//)
      }.should raise_error(RuntimeError, /\Aplease provide a hostname/)
    end

    it "should throw usage on extra args" do
      proc {
        @init.parse_options(%w/aaa bbb/)
      }.should raise_error(RuntimeError, /\Aunexpected: bbb/)
    end

    it "should parse host" do
      opts = @init.parse_options(%w/aaa/)
      opts[:host].should == "aaa"
    end

    it "should parse -u" do
      @init.parse_options(%w/-u host/)[:system_gems].should == 'n'
    end

    it "should parse -N" do
      @init.parse_options(%w/-N node1 host/)[:node].should == "node1"
    end

    it "should parse -t" do
      @init.parse_options(%w/-t host/)[:trace].should == true
    end

    it "should parse -H" do
      @init.parse_options(%w/-H hostname host/)[:hostname].should == "hostname"
    end

  end

  describe :bootstrap do
    it "should raise if mix fails" do
     mock(File).expand_path("files/bootstrap.sh", Blender::ROOT) {"path/to/files/bootstrap.sh"}
     mock(@init).run("cat path/to/files/bootstrap.sh | ssh host USE_SYSTEM_GEMS= TRACE=1 HOSTNAME=foobar.com NODE=zoo /bin/bash -eu") {false}
     proc {
       @init.bootstrap :trace => true, :hostname => "foobar.com", :node => "zoo", :host => "host"
     }.should raise_error(RuntimeError, "failed bootstrap.sh")
    end

    it "should run bootstrap and return true" do
     mock(File).expand_path("files/bootstrap.sh", Blender::ROOT) {"path/to/files/bootstrap.sh"}
     mock(@init).run("cat path/to/files/bootstrap.sh | ssh host USE_SYSTEM_GEMS= TRACE=1 HOSTNAME=foobar.com NODE=zoo /bin/bash -eu") {true}
     @init.bootstrap(:trace => true, :hostname => "foobar.com", :node => "zoo", :host => "host").should == true
    end
  end

end

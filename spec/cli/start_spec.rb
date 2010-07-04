require 'spec_helper'
require 'blender/cli/start'

describe Blender::Cli::Start do
  before(:each) do
    @start = Blender::Cli::Start.new []
  end

  describe :parse_options do
    it "should throw usage on --help" do
      proc {
        @start.parse_options(%w/-h/)
      }.should raise_error(RuntimeError, /\AUsage:/)

      proc {
        @start.parse_options(%w/--help/)
      }.should raise_error(RuntimeError, /\AUsage:/)
    end

    it "should not fail with no parameters" do
      proc {
        @start.parse_options(%w//)
      }.should_not raise_error
    end

    it "should throw usage on extra args" do
      proc {
        @start.parse_options(%w/aaa/)
      }.should raise_error(RuntimeError, /\Aunexpected: aaa/)
    end

    it "should parse -a" do
      @start.parse_options(%w/-a ami123/)[:ami].should == "ami123"
    end

    it "should parse -k" do
      @start.parse_options(%w/-k mykey/)[:key].should == "mykey"
    end

    it "should parse --64" do
      @start.parse_options(%w/--64/)[64].should == true
    end

    it "should parse -n" do
      @start.parse_options(%w/-n/)[:dry].should == true
    end

  end

  describe :default_ami do
    it "should read ~/.blender/ami for 32 bit" do
      mock(File).expand_path("~/.blender/ami") {"/path/to/home/.blender/ami"}
      mock(File).read("/path/to/home/.blender/ami") {"foo"}
      @start.default_ami.should == "foo"
    end

    it "should read ~/.blender/ami64 for 64 bit" do
      mock(File).expand_path("~/.blender/ami64") {"/path/to/home/.blender/ami64"}
      mock(File).read("/path/to/home/.blender/ami64") {"foo"}
      @start.default_ami(64 => true).should == "foo"
    end

    it "should return AMI_32 when file fails to read" do
      mock(File).expand_path("~/.blender/ami") {"/path/to/home/.blender/ami"}
      mock(File).read("/path/to/home/.blender/ami") {raise "boom"}
      @start.default_ami.should == Blender::Cli::Start::AMI_32
    end

    it "should return AMI_32 when file is empty" do
      mock(File).expand_path("~/.blender/ami") {"/path/to/home/.blender/ami"}
      mock(File).read("/path/to/home/.blender/ami") {" "}
      @start.default_ami.should == Blender::Cli::Start::AMI_32
    end
  end

  describe :default_key do
    it "should fail if more then 1 key found" do
      mock(@start).__double_definition_create__.call(:`, "ec2dkey") {"aaa\nbbb"}

      proc {
        @start.default_key
      }.should raise_error(RuntimeError, "too many keys")
    end

    it "should fail if no keys found" do
      mock(@start).__double_definition_create__.call(:`, "ec2dkey") {""}

      proc {
        @start.default_key
      }.should raise_error(RuntimeError, "can't find any keys")
    end

    it "should parse and return single key" do
      mock(@start).__double_definition_create__.call(:`, "ec2dkey") {"KEYPAIR	keyname	12:34:56:78:90"}
      @start.default_key.should == "keyname"
    end

  end

  describe :start_ami do
    it "should start ami with default params" do
      mock(@start).default_ami(anything) {"def-ami"}
      mock(@start).default_key {"def-key"}
      mock(@start).run(*%w"ec2run def-ami -k def-key") {true}
      @start.start_ami.should be_true
    end

    it "should raise error if run fails" do
      mock(@start).default_ami(anything) {"def-ami"}
      mock(@start).default_key {"def-key"}
      mock(@start).run(*%w"ec2run def-ami -k def-key") {false}
      proc {
        @start.start_ami.should be_true
      }.should raise_error(RuntimeError, "failed to start ami")
    end
  end





  #describe :bootstrap do
    #it "should raise if mix fails" do
     #mock(File).expand_path("files/bootstrap.sh", Blender::ROOT) {"path/to/files/bootstrap.sh"}
     #mock(@start).run("cat path/to/files/bootstrap.sh | ssh host USE_SYSTEM_GEMS= TRACE=1 HOSTNAME=foobar.com NODE=zoo /bin/bash -eu") {false}
     #proc {
       #@start.bootstrap :trace => true, :hostname => "foobar.com", :node => "zoo", :host => "host"
     #}.should raise_error(RuntimeError, "failed bootstrap.sh")
    #end

    #it "should run bootstrap and return true" do
     #mock(File).expand_path("files/bootstrap.sh", Blender::ROOT) {"path/to/files/bootstrap.sh"}
     #mock(@start).run("cat path/to/files/bootstrap.sh | ssh host USE_SYSTEM_GEMS= TRACE=1 HOSTNAME=foobar.com NODE=zoo /bin/bash -eu") {true}
     #@start.bootstrap(:trace => true, :hostname => "foobar.com", :node => "zoo", :host => "host").should == true
    #end
  #end

end

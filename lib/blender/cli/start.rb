require 'blender/cli'

class Blender::Cli::Start < Blender::Cli

  AMI_64 = "ami-55739e3c"
  AMI_32 = "ami-bb709dd2"

  def parse_options(args)
    options = {}

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: blender start [OPTIONS] [-- [ec2run options]]"
      opts.separator "Options:"

      opts.on("-a", "--ami AMI",
        "use specified AMI instead of the default one.",
        "If you don't specify your own AMI blender will choose a defaule one:",
        "* #{AMI_32} for 32 bits",
        "* #{AMI_64} for 64 bits",
        "You can change the defaults by writing your own AMIs",
        "into ~/.blender/ami and ~/.blender/ami64 files"
      ) do |val|
        options[:ami] = val
      end

      opts.separator ""

      opts.on("-k", "--key KEY",
        "use KEY when starting instance. KEY should already be generated.",
        "If you don't specify a KEY blender will try to use the key from your EC2 account",
        "Note: There must be only ONE key on the account for it to work."
      ) do |val|
        options[:key] = val
      end
      opts.separator ""

      opts.on("--64", "use 64 bit default AMI. This does nothing if you specify your own AMI") do
        options[64] = true
      end

      opts.on("-n", "--dry-run", "Don't do anything, just print the command line to be executed") do |val|
        @dry = options[:dry] = true
      end

      opts.separator "\nCommon options:"

      opts.on("-h", "--help", "Show this message") do
        raise(opts.to_s)
      end

      opts.on_tail <<-EXAMPLE

Example:

# start a 64bit instance with default options
blender start -64

# start with a custom ami
blender start --ami ami-2d4aa444

# start with passing arguments to ec2run: use security group default+test
blender start -- -g default -g test
       EXAMPLE

    end
    opts.parse!(args)

    raise("unexpected: #{args*" "}\n#{opts}") unless args.empty?

    options
  end

  def default_ami(options = {})
    name = options[64] ? "~/.blender/ami64" : "~/.blender/ami"
    ami = File.read(File.expand_path(name)).strip rescue nil
    ami = options[64] ? AMI_64 : AMI_32 if ami.nil? || ami.empty?
    ami
  end

  def default_key
    keys = `ec2dkey`.strip.split("\n")
    raise("too many keys") if keys.length > 1
    raise("can't find any keys") if keys.length != 1
    keys.first.split("\t")[1].strip || raise("invalid key")
  end

  def start_ami(options = {}, args = [])
    ami = options[:ami] || default_ami(options)
    key = options[:key] || default_key

    cmd = ["ec2run", ami, "-k", key, *args]

    run(*cmd) or raise "failed to start ami"
  end

  def execute
    options = parse_options(@args)
    start_ami(options, *@args)

  rescue => e
    abort(e.to_s)
  end

end
require 'pp'
options = {}

AMI_64 = "ami-55739e3c"
AMI_32 = "ami-bb709dd2"

OptionParser.new do |opts|
  opts.banner = "Usage: blender start [OPTIONS] [-- [ec2run options]]"
  opts.separator "Options:"

  opts.on("--ami AMI",
    "use specified AMI instead of the default one.",
    "If you don't specify your own AMI blender will choose a defaule one:",
    "* #{AMI_32} for 32 bits",
    "* #{AMI_64} for 64 bits",
    "You can change the defaults by writing your own AMIs",
    "into ~/.blender/ami and ~/.blender/ami64 files",
    " "
  ) do |val|
    options[:ami] = val
  end
  opts.on("--key KEY",
    "use KEY when starting instance. KEY should already be generated.",
    "If you don't specify a KEY blender will try to use the key from your EC2 account",
    "Note: There must be only ONE key on the account for it to work. ",
    " "
  ) do |val|
    options[:key] = val
  end

  opts.on("--64", "use 64 bit default AMI. This does nothing if you specify your own AMI") do
    options[64] = true
  end

  opts.on("-n", "--dry-run", "Don't do anything, just print the command line to be executed") do |val|
    options[:dry] = true
  end

  opts.separator ""
  opts.separator "Common options:"

  opts.on("-h", "--help", "Show this message") do
    puts opts
    exit
  end

end.parse!

def default_ami(options)
  name = options[64] ? "~/.blender/ami64" : "~/.blender/ami"
  ami = File.read(File.expand_path(name)) rescue nil
  ami = options[64] ? AMI_64 : AMI_32 if ami.nil? || ami.empty?
  ami
end

def default_key(options)
  keys = `ec2dkey`.strip.split("\n")
  abort("too many keys") if keys.length > 1
  abort("can't find any keys") if keys.length != 1
  keys.first.split("\t")[1] || raise("invalid key")
end

ami = options[:ami] || default_ami(options)
key = options[:key] || default_key(options)

cmd = ["ec2run", ami, "-k", key, *ARGV]
puts cmd * " "
system(*cmd) unless options[:dry]
require 'pp'
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: blender start [options] [-- [ec2run options]]"

  opts.on("--ami AMI") { |val| options[:ami] = val }
  opts.on("--key KEY") { |val| options[:key] = val }
  opts.on("--options OPTIONS") { |val| options[:ami] = val }
  opts.on("--64") { options[64] = true }

end.parse!

def default_ami(options)
  name = options[64] ? "~/.blender/ami64" : "~/.blender/ami"
  ami = File.read(File.expand_path(name)) rescue nil
  ami = options[64] ? "ami-eef61587" : "ami-ccf615a5" if ami.nil? || ami.empty?
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
system *cmd
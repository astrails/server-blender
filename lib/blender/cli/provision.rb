options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: blender provision"
  
  opts.on("--ami AMI") { |val| options[:ami] = val }
  opts.on("--options OPTIONS") { |val| options[:ami] = val }
  
end.parse!

command = "ec2run"

command << " " << options[:options] if options[:options] << ??
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: blender init [options] HOST"
  
end.parse!

abort("please provide a hostname") unless host = ARGV.shift

system("scp", path("files/bootstrap.sh"), "#{host}:/tmp/bootstrap.sh") &&
system("scp", path("files/apt/ubuntu-intrepid-ec2-sources.list"), "#{host}:/tmp/apt-sources.list") &&
system("ssh", host, "bash /tmp/bootstrap.sh")
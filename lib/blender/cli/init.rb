options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: blender init [options] HOST"
  
end.parse!

abort("please provide a hostname") unless host = ARGV.shift

system("scp", path("files/bootstrap.sh"), "#{host}:/tmp/bootstrap.sh") &&
system("ssh", host, "/bin/bash /tmp/bootstrap.sh")

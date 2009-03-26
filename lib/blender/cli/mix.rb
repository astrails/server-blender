options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: blender mix [options] MANIFESTS_DIR HOST"
  
end.parse!

dir = ARGV.shift
abort("please provide a manifests directory") unless dir && File.directory?(dir)
host = ARGV.shift
abort("please provide a hostname") unless host

system("rsync -azP --delete #{dir}/ #{host}:/tmp/blender") &&
system("scp", path("files/apt/ubuntu-intrepid-ec2-sources.list"), "#{host}:/tmp/apt-sources.list") &&
system("ssh", host, "echo Running Puppet...;shadow_puppet /tmp/blender/default.rb")


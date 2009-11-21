options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: blender init [OPTIONS] HOST"
  opts.separator ""
  opts.separator "Common options:"

  opts.on("-h", "--help", "Show this message") do
    puts opts
    exit
  end

end.parse!

abort("please provide a hostname") unless host = ARGV.shift

system("scp", path("files/bootstrap.sh"), "#{host}:/tmp/bootstrap.sh") &&
system("ssh", host, "/bin/bash /tmp/bootstrap.sh")

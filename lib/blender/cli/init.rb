options = {
  :system_gems => 'y'
}
OptionParser.new do |opts|
  opts.banner = "Usage: blender init [OPTIONS] HOST"
  opts.separator ""
  opts.separator "Common options:"

  opts.on("-u", "--upstream-gems", "don't use the system gems, download and install upstream version instead") do
    options[:system_gems] = 'n'
  end

  opts.on("-N", "--node NODE", "force NODE as the current nodename") do |val|
    options[:node] = val
  end

  opts.on("-t", "--trace", "dump trace to the stdout") do |val|
    options[:trace] = true
  end

  opts.on("-H", "--hostname HOSTNAME", "set HOSTNAME") do |val|
    options[:hostname] = val
  end

  opts.on("-h", "--help", "Show this message") do
    puts opts
    exit
  end

end.parse!

abort("please provide a hostname") unless host = ARGV.shift

extra=""
extra << " TRACE=1" if options[:trace]
extra << " HOSTNAME=#{options[:hostname]}" if options[:hostname]
extra << " NODE=#{options[:node]}" if options[:node]

def run(*cmd)
  puts ">> #{cmd * ' '}"
  system(*cmd)
end

run "cat #{File.expand_path("files/bootstrap.sh", Blender::ROOT)} | ssh #{host} USE_SYSTEM_GEMS=#{options[:system_gems]}#{extra} /bin/bash -eu"

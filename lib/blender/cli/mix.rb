options = {
  :recipe => 'default'
}
opts = OptionParser.new do |opts|
  opts.banner = "Usage: blender mix [OPTIONS] [DIR] HOST"
  opts.separator "Options:"

  opts.on("-r", "--recipe RECIPE", "('default' will be used if RECIPE not specified") do |val|
    options[:recipe] = val
  end

  opts.on("-N", "--node NODE", "force NODE as the current nodename") do |val|
    options[:node] = val
  end

  opts.on("-R", "--roles ROLES", "comma delimited list of roles that should execute") do |val|
    options[:roles] = val
  end

  opts.separator ""
  opts.separator "Common options:"

  opts.on("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.separator ""
  opts.separator "Notes:"
  opts.separator '    "." used if DIR not specified'

end
opts.parse!

dir = ARGV.shift
host = ARGV.shift
abort("unexpected: #{ARGV*" "}\n#{opts}") unless ARGV.empty?
if host.nil?
  host = dir
  dir = "."
end

abort(opts.to_s) unless dir && host

unless File.directory?(dir)
  puts "#{dir} is not a directory"
  abort(opts.to_s)
end

File.file?(File.join(dir, recipe = options[:recipe])) ||
  File.file?(File.join(dir, recipe = "#{options[:recipe]}.rb")) ||
  abort("recipe #{options[:recipe]} not found\n#{opts}")

WORK_DIR = "/var/lib/blender/recipes"

def run(*cmd)
  puts ">> #{cmd * ' '}"
  system(*cmd)
end

run("rsync -azP --delete --exclude '.*' #{dir}/ #{host}:#{WORK_DIR}") &&

env_config = "RECIPE=#{recipe}"
env_config << " NODE=#{options[:node]}" if options[:node]
env_config << " ROLES=#{options[:roles]}" if options[:roles]

run "cat #{File.expand_path("files/mix.sh", Blender::ROOT)} | ssh #{host} #{env_config} /bin/bash -eu"

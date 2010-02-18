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

recipe = "#{options[:recipe]}.rb"
unless File.file?(File.join(dir, recipe))
  puts "recipe #{recipe} not found"
  abort(opts.to_s)
end

WORK_DIR = "/var/lib/blender/recipes"
LOCAL_MANIFEST_DIR = File.expand_path("../../manifest", __FILE__)
REMOTE_MANIFEST_DIR = "/var/lib/blender/manifest"
ROOT_MANIFEST = File.join(REMOTE_MANIFEST_DIR, "root.rb")

def run(*cmd)
  puts ">> #{cmd * ' '}"
  system(*cmd)
end
run("rsync -azP --delete --exclude '.*' --exclude other #{LOCAL_MANIFEST_DIR}/ #{host}:#{REMOTE_MANIFEST_DIR}") &&
run("rsync -azP --delete --exclude '.*' #{dir}/ #{host}:#{WORK_DIR}") &&

extra=""
extra << " NODE=#{options[:node]}" if options[:node]
extra << " ROLES=#{options[:roles]}" if options[:roles]

run("ssh", host, "echo 'Running Puppet [recipe: #{recipe}]...';cd #{WORK_DIR} && RECIPE=#{recipe} #{extra} shadow_puppet #{ROOT_MANIFEST}")

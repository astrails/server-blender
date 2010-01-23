options = {
  :recipe => 'default'
}
opts = OptionParser.new do |opts|
  opts.banner = "Usage: blender mix [OPTIONS] [DIR] HOST"
  opts.separator "Options:"

  opts.on("-r", "--recipe RECIPE", "('default' will be used if RECIPE not specified") do |val|
    options[:recipe] = val
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
ROOT_MANIFEST = File.expand_path("../../manifest/root.rb", __FILE__)

cmd = "rsync -azP --delete --exclude other --exclude '.*' #{dir}/ #{host}:#{WORK_DIR}"
puts cmd
system(cmd) &&
system("ssh", host, "echo 'Running Puppet [recipe: #{recipe}]...';cd #{WORK_DIR} && RECIPE=#{recipe} shadow_puppet #{ROOT_MANIFEST}")

options = {
  :recipe => 'default'
}
opts = OptionParser.new do |opts|
  opts.banner = <<-USAGE
Usage: blender mix [options] [DIR]  HOST

Note: "." used if DIR not specified

Options:
USAGE

  opts.on("-r", "--recipe RECIPE", "('default' will be used if -r not specified") do |val|
    options[:recipe] = val
  end
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

RECIPES = "/var/lib/blender/recipes"
cmd = "rsync -azP --delete --exclude other --exclude '.*' #{dir}/ #{host}:#{RECIPES}"
puts cmd
system(cmd) &&
system("ssh", host, "echo 'Running Puppet [recipe: #{recipe}]...';cd #{RECIPES} && shadow_puppet #{RECIPES}/#{recipe}")

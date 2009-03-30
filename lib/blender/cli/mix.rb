USAGE = "Usage: blender mix [options] RECIPES_DIR HOST"
options = {
  :recipe => 'default'
}
opts = OptionParser.new do |opts|
  opts.banner = USAGE

  opts.on("-r", "--recipe RECIPE") do |val|
    options[:recipe] = val
  end
end
opts.parse!

dir = ARGV.shift
host = ARGV.shift

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


system("rsync -azP --delete #{dir}/ #{host}:/tmp/blender") &&
system("scp", path("files/apt/ubuntu-intrepid-ec2-sources.list"), "#{host}:/tmp/apt-sources.list") &&
system("ssh", host, "echo 'Running Puppet [recipe: #{recipe}]...';shadow_puppet /tmp/blender/#{recipe}")
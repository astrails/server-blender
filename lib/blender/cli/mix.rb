def parse_options
  options = {}
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: blender mix [OPTIONS] [DIR] HOST"
    opts.separator "Options:"

    opts.on("-r", "--recipe RECIPE", "if RECIPE is not specified blender will first look for <directory_name>.rb and then for blender-recipe.rb") do |val|
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
      raise(opts.to_s)
    end

    opts.separator ""
    opts.separator "Notes:"
    opts.separator '    "." used if DIR not specified'

  end
  opts.parse!

  options[:usage] = opts.to_s

  dir = ARGV.shift
  host = ARGV.shift
  raise("unexpected: #{ARGV*" "}\n#{opts}") unless ARGV.empty?

  if host.nil?
    host = dir
    dir = "."
  end

  raise(opts.to_s) unless dir && host

  raise("#{dir} is not a directory\n#{opts}") unless File.directory?(dir)

  options.merge(:dir => dir, :host => host)
end


def find_recipe(options)
  # check for recipe, recipe.rb, directory_name.rb, and default.rb
  recipes = []
  if rname = options[:recipe]
    recipes << rname << "#{rname}.rb"
  end
  recipes << "#{File.basename(File.expand_path(options[:dir]))}.rb" << "blender-recipe.rb"

  recipe = recipes.detect {|r| File.file?(File.join(options[:dir], r))} ||
    raise("recipe not found (looking for #{recipes * ' '})\n#{options[:usage]}")
end

def run(*cmd)
  STDERR.puts ">> #{cmd * ' '}"
  system(*cmd)
end


def run_recipe(recipe, options)
  run "cat #{File.expand_path("files/init.sh", Blender::ROOT)} | ssh #{options[:host]} /bin/bash -eu" or raise("failed init.sh")

  run("rsync -qazP --delete --exclude '.*' #{options[:dir]}/ #{options[:host]}:/var/lib/blender/recipes") or raise("failed rsync")

  env_config = "RECIPE=#{recipe}"
  env_config << " NODE=#{options[:node]}" if options[:node]
  env_config << " ROLES=#{options[:roles]}" if options[:roles]

  run "cat #{File.expand_path("files/mix.sh", Blender::ROOT)} | ssh #{options[:host]} #{env_config} /bin/bash -eu" or raise("failed mix.sh")
end

def main
  options = parse_options
  recipe = find_recipe(options)
  run_recipe(recipe, options)

rescue => e
  abort(e.to_s)
end

require 'blender/cli'

class Blender::Cli::Init < Blender::Cli
  def parse_options(args)
    options = {
      :system_gems => 'y'
    }
    opts = OptionParser.new do |opts|
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
        raise(opts.to_s)
      end

    end.parse!(args)

    raise("please provide a hostname\n#{opts}") unless host = args.shift

    raise("unexpected: #{args*" "}\n#{opts}") unless args.empty?

    options.merge(:host => host)
  end

  def bootstrap(options)
    extra=""
    extra << " TRACE=1" if options[:trace]
    extra << " HOSTNAME=#{options[:hostname]}" if options[:hostname]
    extra << " NODE=#{options[:node]}" if options[:node]

    run "cat #{File.expand_path("files/bootstrap.sh", Blender::ROOT)} | ssh #{options[:host]} USE_SYSTEM_GEMS=#{options[:system_gems]}#{extra} /bin/bash -eu" or raise "failed bootstrap.sh"
  end

  def execute
    options = parse_options(@args)
    bootstrap(options)

  rescue => e
    abort(e.to_s)
  end
end

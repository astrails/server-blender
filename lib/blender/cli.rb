module Blender
  class Cli
    def initialize(args)
      @args = args
    end

    def run(*cmd)
      STDERR.puts ">> #{cmd * ' '}"
      system(*cmd) unless @dry
    end

  end
end

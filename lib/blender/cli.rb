module Blender
  class Cli
    def initialize(args)
      @args = args
    end

    def run(*cmd)
      STDERR.puts ">> #{cmd * ' '}"
      @dry || system(*cmd)
    end

  end
end

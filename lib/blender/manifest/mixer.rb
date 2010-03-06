module Blender
  module Manifest
    # Well, I'm already not 100% sure this is needed :)
    # The purpose is to make the mixing of recipes cleaner and easier on the eyes :)
    #
    # i.e. instead of
    #     require 'foo'
    #     include Blender::Recipes::Foo
    #     require 'bar'
    #     include Blender::Recipes::Bar
    # you can just
    #     mix :foo, :bar
    module Mixer

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        @@mix_from = nil

        # set the recipes directory
        # All subsequent `mix` calls can be done relative to this directory
        # @param base base recipes directory
        def mix_from(base)
          @@mix_from = base
        end

        @@mix_namespace = "Blender::Recipes"
        def mix_namespace(namespace)
          @@mix_namespace = namespace
        end

        # internal: add the mix recipes base directory to the load path
        # if recipes directory was not yet set using the `mix_from` call
        # it will try to detect it
        def setup_mix_path
          # try to detect if was not set by the user
          @@mix_from ||= [
            "lib/astrails/blender/recipes",
            "lib/blender/recipes",
            "lib/astrails/recipes",
            "lib/recipes",
            "recipes",
            "."].detect {|f| File.directory?(f)}
          $: << @@mix_from unless $:.include?(@@mix_from)
        end

        @@mixed_recipes = []

        # mix recipes Module
        # @param [String, Array] recipes to mix
        def mix(*recipes)

          recipes.each do |recipe|

            case recipe
            when String, Symbol
              recipe = recipe.to_s

              next if @@mixed_recipes.include?(recipe)
              @@mixed_recipes << recipe

              setup_mix_path
              require recipe
              mixin =
                begin
                  recipe = recipe.to_s.camelize
                  recipe = "#{@@mix_namespace}::#{recipe}" if @@mix_namespace
                  recipe.constantize
                end
            when Module
              mixin = recipe
            else
              raise "Expecting String, Symbol or Module. don't know what do do with #{recipe.inspect}"
            end

            Root.send :include, mixin
          end
        end

      end

      # set the recipes directory
      # All subsequent `mix` calls can be done relative to this directory
      # @param base base recipes directory
      def mix_from(base)
        self.class.mix_from(base)
      end

      # mix recipes Module
      # @param [String, Array] recipes to mix
      def mix(*recipes)
        self.class.mix(*recipes)
      end

    end
  end
end

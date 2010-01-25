module Blender
  module Manifest
    module Mixer

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        @@mix_from = [
          "lib/astrails/blender/recipes",
          "lib/blender/recipes",
          "lib/astrails/recipes",
          "lib/recipes",
          "recipes",
          "."].detect {|f| File.directory?(f)}

        def mix_from(base)
          @@mix_from = base
        end

        # UGLY HACK! class_eval picks up the local binding
        # and so local variable can shaddow functions from the mixed recipe
        # using ugly long variable names to *somewhat* mitigate the problem
        @@mixed_recipes = []
        def mix(*recipes_2_mix)

          if recipes_2_mix.last.is_a?(Hash)
            recipes_2_mix_options = recipes_2_mix.pop
          else
            recipes_2_mix_options = {}
          end

          recipes_2_mix.each do |recipe_2_mix_name|
            recipe_2_mix = recipe_2_mix_name.to_s
            if recipe_2_mix =~ /^[a-z]{2,8}:\//
              # seems like a url. leave as-is
            else
              recipe_2_mix = File.expand_path(recipe_2_mix, @@mix_from)
              recipe_2_mix = "#{recipe_2_mix}.rb" unless recipe_2_mix =~ /\.rb$/
            end
            next if @@mixed_recipes.include?(recipe_2_mix)
            @@mixed_recipes << recipe_2_mix
            code = open(recipe_2_mix).read
            class_eval(code, recipe_2_mix)
            class_eval("recipe :#{recipe_2_mix_name}") if recipes_2_mix_options[:run]
          end
        end

      end

      def mix_from(base)
        self.class.mix_from(base)
      end

      def mix(*recipes_2_mix)
        self.class.mix(*recipes_2_mix)
      end

    end
  end
end

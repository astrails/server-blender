require 'ruby-debug'
$: << File.dirname(__FILE__) # FIXME: remove?

module Blender
  module Manifest; end
  module Recipes; end
end
require 'init'
require 'nodes'
require 'roles'
require 'mixer'

class Root < ::ShadowPuppet::Manifest
  include Blender::Manifest::Init
  include Blender::Manifest::Nodes
  include Blender::Manifest::Roles

  @@mixed_recipes = []
  def self.mixed_recipes
    @@mixed_recipes
  end

  def execute_user_recipe
    raise "no RECIPE to execute" unless recipe = ENV['RECIPE']

    code = open(recipe).read
    instance_eval(code, recipe)
  end
  recipe :execute_user_recipe
end

include Blender::Manifest::Mixer

# "standard" recipe directories
$: << "recipes" << "recipes/astrails" << "lib/astrails/blender/recipes"

# add all libs in the ./vendor directory to the path
$:.concat Dir["vendor/*/"]
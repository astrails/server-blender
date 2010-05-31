require 'ruby-debug'
$: << File.dirname(__FILE__) # FIXME: remove?

require 'init'
require 'nodes'
require 'roles'
require 'mixer'

# "standard" recipe directories
$: << "recipes" << "recipes/astrails" << "lib/astrails/blender/recipes"

# add all libs in the ./vendor directory to the path
$:.concat Dir["vendor/*/"]

class Root < ::ShadowPuppet::Manifest
  include Init
  include Nodes
  include Roles

  def execute_user_recipe
    raise "no RECIPE to execute" unless recipe = ENV['RECIPE']

    code = open(recipe).read
    instance_eval(code, recipe)
  end
  recipe :execute_user_recipe
end

include Blender::Manifest::Mixer
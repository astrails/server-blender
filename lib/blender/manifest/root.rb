require 'ruby-debug'
$: << File.dirname(__FILE__)
require 'init'
require 'nodes'
require 'roles'
require 'mixer'

module Blender
  module Manifest
    class Root < ::ShadowPuppet::Manifest
      include Init
      include Nodes
      include Roles
      include Mixer

      def execute_user_recipe
        raise "no RECIPE to execute" unless recipe = ENV['RECIPE']

        code = open(recipe).read
        instance_eval(code, recipe)
      end
      recipe :execute_user_recipe
    end
  end
end
# shadow_puppet expects to find module Foo inside file foo.rb
Root = Blender::Manifest::Root
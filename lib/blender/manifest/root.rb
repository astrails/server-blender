require 'nodes'
require 'roles'

module Blender
  module Manifest
    class Root < ::ShadowPuppet::Manifest
      include Nodes
      extend Nodes
      include Roles
      extend Roles

      def execute_user_recipe
      end
      recipe :execute_user_recipe
    end
  end
end
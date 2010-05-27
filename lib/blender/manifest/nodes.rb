# This module encapsulates nodes handeling
# Nodes can be declared both on a class level and inside a recipe
# When defining a node an 'id' is associated with its hostname
# and the node can later be reffered by this id (for example
# to get its ip)
module Blender
  module Manifest
    module Nodes

      def self.included(base)
        base.send :extend, self
      end

      # this holds the map from host ids to hostnames
      @@internal_hostnames = {}
      @@external_hostnames = {}

      # returns hostname by id or local host's name if the id is nil
      def hostname(id = nil, external = false)
        if id
          (external ? @@external_hostnames : @@internal_hostnames)[id]
        else
          external ? Facter.fqdn : Facter.hostname
        end
      end

      # returns id of the node we are running at
      # Note: will ONLY return non-nil value after (or during) node definition
      #   unless node is forced by environment NODE variable or /etc/node file
      def current_node
        node = ENV['NODE'] ||
          (File.exists?("/etc/node") && File.read("/etc/node").strip) ||
          @@internal_hostnames.index(hostname) ||
          @@external_hostnames.index(hostname(nil, true))
        node && node.to_sym
      end

      # @return true if we are running on the node with the given `id`
      def current_node?(id)
        current_node == id.to_sym
      end

      # resolves host name using 'host' executable
      # @return host's IP by its name or nil if not found
      def host_ip(name)
        res = `host #{name}`.split("\n").grep(/has address/).first
        res && res.split.last
      end

      # define node and conditionally execute code block only on the specific node
      # Note: can be called multiple times without internal_name and external_name parameters
      #   in which case will only do the conditional execution
      # @param [Symbol, String] id of the host to define or test for
      # @param [String] internal_name short hostname for the host
      # @param [String] external_name full dns hostname for the host
      # @example
      #    node :app, "host5", "host5.serverfarm2.localdomain" do
      #      ...
      #    end
      #
      #    node :app do
      #      ...
      #    end
      #
      def node(id, internal_name = nil, external_name = internal_name)
        return if false == internal_name # can be used to temporary 'disable' host's definition
                                         # like:
                                         # host :app2, false do .. end
        @@internal_hostnames[id] = internal_name if internal_name
        @@external_hostnames[id] = external_name if external_name

        if block_given? && current_node?(id)
          puts "NODE: #{id} / #{current_node}"
          @node = id
          yield
        end
      end

      # find out node addr. try to use external, then internal, then the host id to determine ip
      # @param [Symbol, String] id id of the host to resolve
      def addr(id)
        [hostname(id, true).to_s, hostname(id).to_s, id.to_s].each do |name|
          ip = host_ip(name)
          return ip if ip
        end

        # if all else fails, we should still be able to address the current node
        current_node?(id) ? "127.0.0.1" : nil
      end

      # same as addr but throws exception if IP can't be found
      def addr!(id)
        addr(id) or raise "Can't find address for '#{id}'"
      end

    end
  end
end
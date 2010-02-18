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
      @@internal_hostnames = {nil => Facter.hostname}
      @@external_hostnames = {nil => Facter.fqdn}

      # returns hostname by id or local host's name if the id is nil
      # will return the id itself if it can't find the mapping
      def hostname(id = nil, external = false)
        (external ? @@external_hostnames : @@internal_hostnames)[id] || id.to_s
      end

      # return host's IP by its name
      def host_ip(name)
        res = `host #{name}`.split("\n").grep(/has address/).first
        res && res.split.last
      end

      # find out node addr. try to use external, then internal, then the host id to determine ip
      def addr(id)
        [
          hostname(id, true),
          hostname(id),
          id
        ].compact.uniq.map{|h| host_ip(h)}.compact.first ||
          (current_node?(id) && "127.0.0.1") # if all else fails, we should still be able to address the current node
      end

      # same as addr but throws exception if IP can't be found
      def addr!(id)
        addr(id) or raise "Can't find address for '#{id}'"
      end

      def current_node
        ENV['NODE'] ||
        (File.exists?("/etc/node") && File.read("/etc/node").strip) ||
        hostname
      end

      def current_node?(id)
        [id.to_s, @@internal_hostnames[id], @@external_hostnames[id]].compact.include?(current_node)
      end

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

    end
  end
end
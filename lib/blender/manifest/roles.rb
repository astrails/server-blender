module Blender::Manifest::Roles

  def self.included(base)
    base.send :extend, self
  end

  # A very simple mechanism to define roles
  #
  # Roles to accept can be defined from environment, /etc/roles file
  # or can be explicitly defined like 'roles xxx, yyy'
  # usually the 'roles a,b,c' call will come inside of
  # a `node` block and so will be conditionally executed depending on the
  # running host

  def current_roles
    @current_roles ||=
      if ENV['ROLES']
        ENV['ROLES'].split(",")
      elsif File.exists?("/etc/roles")
        File.read("/etc/roles").strip.split
      else
        []
      end
  end

  # ADDS roles to the currently defined roles
  def roles *roles
    current_roles.concat(roles.map {|r| r.to_s})
  end

  # conditionally runs the code block if the role 'r' is
  # currently defined
  def role r
    if block_given? && current_roles.include?(r.to_s)
      puts "ROLE: #{r}"
      yield
    end
  end

end
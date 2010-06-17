#!/bin/bash -eu

SHADOW_PUPPET_VERSION="0.3.2"
MANIFEST_VERSION="0.0.11"

trap "echo FAILED" EXIT

# ensure_gem GEM [VERSION]
function ensure_gem()
{
	if [ $# -eq 2 ]; then
		# name + version
		if ! gem list $1 | grep -q "$1 (\([^,]*, \)*${2//./\\.}\(, [^,]*\)*)$"; then
			echo installing $1 $2
			gem install --no-ri --no-rdoc $1 -v$2
		fi
	else
		# name only
		if ! gem list $1 | grep -q "^$1 ";then
			echo installing $1
			gem install --no-ri --no-rdoc $1
		fi
	fi
}

ensure_gem shadow_puppet $SHADOW_PUPPET_VERSION
ensure_gem ruby-debug
ensure_gem server-blender-manifest $MANIFEST_VERSION

echo "Mix: [recipe: $RECIPE, node: ${NODE:-}, roles: ${ROLES:-}]"

cd /var/lib/blender/recipes

ruby -rrubygems <<-RUBY
gem 'server-blender-manifest', '$MANIFEST_VERSION'
require 'blender/manifest'
Blender::Manifest.run("${SHADOW_PUPPET_VERSION}") || exit(1)
RUBY

trap - EXIT

echo
echo Your ServerShake is ready. Have fun!

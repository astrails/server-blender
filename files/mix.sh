#!/bin/bash -eu

SHADOW_PUPPET_VERSION="0.3.2"
MANIFEST_VERSION="0.0.14"

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

function use_system_ruby() {
	if [ -e /usr/local/rvm ]; then
		echo RVM: Switch to system ruby
		set +eu
		. /usr/local/rvm/scripts/rvm
		rvm use system
		set -eu
	fi
}

function run_recipe() {
	echo "Mix: [recipe: $RECIPE, node: ${NODE:-}, roles: ${ROLES:-}]"

	# rvm substitutes cd with its scripts/cd which accesses unbound variables
	set +u
	cd /var/lib/blender/recipes
	set -u

	ruby -rrubygems <<-RUBY
gem 'server-blender-manifest', '$MANIFEST_VERSION'
require 'blender/manifest'
Blender::Manifest.run("${SHADOW_PUPPET_VERSION}") || exit(1)
RUBY
}

use_system_ruby
ensure_gem shadow_puppet $SHADOW_PUPPET_VERSION
ensure_gem ruby-debug
ensure_gem server-blender-manifest $MANIFEST_VERSION
if run_recipe; then
	echo
	echo "Your ServerShake is ready. Have fun!"
else
	echo
	echo "Failed to mix your ServerShake. Check error messages above for details"
fi

trap - EXIT

#!/bin/bash -eu

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

ensure_gem shadow_puppet 0.3.2
ensure_gem ruby-debug
ensure_gem server-blender-manifest 0.0.9

cd /var/lib/blender/recipes
echo "Running Puppet [recipe: $RECIPE]"

blender-mix-recipe $RECIPE

trap - EXIT

echo
echo Your ServerShake is ready

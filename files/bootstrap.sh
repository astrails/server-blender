#!/bin/bash -e

cat <<_
Bootstraping blender...
Date: `date`
Hostname: `hostname`
System: `uname -a`
_

MIN_MAJOR=8
MIN_MINOR=10

set -x

function supported_version()
{
	. /etc/lsb-release
	[[ "$DISTRIB_ID" == "Ubuntu" && "${DISTRIB_RELEASE%.*}" -ge "$MIN_MAJOR" && "${DISTRIB_RELEASE#*.}" -ge "$MIN_MINOR" ]]
}

if !supported_version; then
	echo "minimal version required: $MIN_MAJOR:$MIN_MINOR"
	exit
fi

mv /tmp/apt-sources.list /etc/apt/sources.list

apt-get update
apt-get upgrade -qy
apt-get autoremove -qy

apt-get install -qy ruby rubygems

gem install --no-rdoc --no-ri shadow_puppet
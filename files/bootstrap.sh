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

apt-get update
apt-get upgrade -qy
apt-get autoremove -qy

apt-get install -q -y git-core build-essential zlib1g-dev libssl-dev libreadline5-dev wget
apt-get install -q -y ruby-full

pushd /tmp
wget http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz
tar xfz rubygems-1.3.1.tgz
pushd rubygems-1.3.1
ruby setup.rb
ln -s /usr/bin/gem1.8 /usr/bin/gem
gem update --system

gem install --no-rdoc --no-ri shadow_puppet

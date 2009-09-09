#!/bin/bash -e

cat <<_
Bootstraping blender...
Date: `date`
Hostname: `hostname`
System: `uname -a`
_

# blender
mkdir -p /var/lib/blender/{recipes,logs,tmp}
chmod 0700 /var/lib/blender/

exec 1>> /var/lib/blender/logs/blender-bootstrap.log
exec 2>&1

MIN_MAJOR=9
MIN_MINOR=4

set -x

function supported_version()
{
	. /etc/lsb-release
	[[ ("$DISTRIB_ID" == "Ubuntu") && (("${DISTRIB_RELEASE%.*}" -gt "$MIN_MAJOR") || (("${DISTRIB_RELEASE%.*}" -eq "$MIN_MAJOR") && ("${DISTRIB_RELEASE#*.}" -ge "$MIN_MINOR"))) ]]
}

if ! supported_version; then
	echo "minimal version required: $MIN_MAJOR:$MIN_MINOR"
	exit
fi

# protect ec2-ami-tools from downgrade

cat <<-PREFS >/etc/apt/preferences
Package: ec2-ami-tools
Pin: version 1.3-34545
Pin-Priority: 500
PREFS

# update
apt-get update
apt-get upgrade -qy
apt-get autoremove -qy

# setup etckeeper
apt-get -q -y install git-core etckeeper
cp /etc/etckeeper/etckeeper.conf /etc/etckeeper/etckeeper.conf.orig
(rm /etc/etckeeper/etckeeper.conf; awk "/^\s*VCS=/{sub(/.*/, \"VCS=git\")};{print}" > /etc/etckeeper/etckeeper.conf) < /etc/etckeeper/etckeeper.conf
etckeeper init
etckeeper commit "import during bootstrap"

# ruby
apt-get install -q -y build-essential zlib1g-dev libssl-dev libreadline5-dev wget
apt-get install -q -y ruby irb ruby-dev libopenssl-ruby

# rubygems
apt-get install -q -y rubygems
gem source -a http://gems.github.com
## apt-get remove -qy --purge rubygems
## apt-get autoremove -qy
##
## pushd /tmp
## wget http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz
## tar xfz rubygems-1.3.1.tgz
## pushd rubygems-1.3.1
## ruby setup.rb
## ln -s /usr/bin/gem1.8 /usr/bin/gem
## gem update --system

# shadow puppet
gem install --no-rdoc --no-ri puppet -v 0.24.8
gem install --no-rdoc --no-ri shadow_puppet -v 0.3.0
gem install --no-rdoc --no-ri ruby-debug


# PATH ####################

## # default /etc/login.defs
## ENV_SUPATH      PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
## ENV_PATH        PATH=/usr/local/bin:/usr/bin:/bin:/usr/games
## # default /etc/environment
## PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
##
## When loggin-in over SSH /etc/environment path is active
## When doing "su - xxx" - /etc/login.defs path is active

etckeeper commit "before PATH update"

ENV_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/var/lib/gems/1.8/bin
USER_PATH=/usr/local/bin:/usr/bin:/bin:/usr/games:/var/lib/gems/1.8/bin
ROOT_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/gems/1.8/bin

cat <<-ENV>/etc/environment
PATH="$ENV_PATH"
ENV

( rm /etc/login.defs; awk "/^\s*ENV_SUPATH/{sub(/.*/, \"ENV_SUPATH      PATH=$ROOT_PATH\")};/^\s*ENV_PATH/{sub(/.*/, \"ENV_PATH        PATH=$USER_PATH\")};{print}" > /etc/login.defs ) < /etc/login.defs

etckeeper commit "after PATH update"

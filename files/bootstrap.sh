#!/bin/bash -eu

# log both to the 'real' stdout and into the log
function log()
{
	echo "************* $@"
	echo "************* $@" >&3
}

trap "log FAILED" EXIT

function banner()
{
	cat <<_
Bootstraping blender...
Date: `date`
Hostname: `hostname`
System: `uname -a`
_
}

function setup_node()
{
	if [ -n "${NODE:-}" ]; then
		echo SET NODE: $NODE
		echo $NODE > /etc/node
	fi
}

function setup_hostname()
{
	if [ -n "${HOSTNAME:-}" ]; then
		echo SET HOSTNAME: $HOSTNAME
		echo $HOSTNAME > /etc/hostname
		hostname $HOSTNAME
	fi
}

# initialize blender directory and redirect output to the log file
function blender_init()
{
	mkdir -p /var/lib/blender/{recipes,logs,tmp}
	chmod 0700 /var/lib/blender/

	# save stdout into fd 3
	exec 3>&1

	# redirect stdout/error to the log
	if [ -n "${TRACE:-}" ]; then
		exec 1 | tee -a /var/lib/blender/logs/blender-bootstrap.log
	else
		exec 1>> /var/lib/blender/logs/blender-bootstrap.log
	fi
	exec 2>&1

	cd /tmp
	# lets log everything
	set -x
}


function distribution()
{
	echo "$DISTRIB_ID $DISTRIB_RELEASE"
}

function supported_version()
{
	. /etc/lsb-release

	case "`distribution`" in
		"Ubuntu 10.04") true;;
	  *) false;;
	esac
}

function check_version()
{
	if ! supported_version; then
		log "`distribution` is not supported"
		exit
	fi
}

# protect ec2-ami-tools from downgrade
function pin_ami_version()
{
	cat <<-PREFS >/etc/apt/preferences
Package: ec2-ami-tools
Pin: version 1.3-34545
Pin-Priority: 500
PREFS
}

function update_apt()
{
	log "updating apt"
	apt-get update
	apt-get upgrade -qy
	apt-get autoremove -qy
}

function setup_etckeeper()
{
	log "installing etckeeper"
	apt-get -q -y install git-core etckeeper
	cp /etc/etckeeper/etckeeper.conf /etc/etckeeper/etckeeper.conf.orig
	# etckeeper comes configured for bazr. use git instead.
	(rm /etc/etckeeper/etckeeper.conf; awk "/^\s*VCS=/{sub(/.*/, \"VCS=git\")};{print}" > /etc/etckeeper/etckeeper.conf) < /etc/etckeeper/etckeeper.conf
	etckeeper init
	etckeeper commit "import during bootstrap" || true
}


function install_stuff()
{
	log "installing required packages"
	apt-get install -q -y rsync build-essential zlib1g-dev libssl-dev libreadline5-dev wget bind9-host
}

function install_system_ruby()
{
	log "installing system ruby"
	apt-get install -q -y ruby irb ruby-dev libopenssl-ruby
}

function install_system_rubygems()
{
	log "installing system rubygems"
	apt-get install -q -y rubygems
	gem source -a http://gemcutter.org
}

function upgrade_rubygems()
{
	log "upgrading rubygems"
	gem install --no-rdoc --no-ri rubygems-update
	update_rubygems
}

UPSTREAM_GEMS_VERSION=1.3.6
function install_custom_rubygems()
{
	log "installing custom rubygems"
	# remove system rubygems if exist
	apt-get remove -qy --purge rubygems
	apt-get autoremove -qy

	# download and install gems
	cd /tmp
	wget http://production.cf.rubygems.org/rubygems/rubygems-$UPSTREAM_GEMS_VERSION.tgz
	tar xfz rubygems-$UPSTREAM_GEMS_VERSION.tgz
	pushd rubygems-$UPSTREAM_GEMS_VERSION
	ruby setup.rb --no-rdoc --no-ri
	ln -sfn /usr/bin/gem1.8 /usr/bin/gem
}

function install_puppet()
{
	log "installing puppet"
	gem install --no-rdoc --no-ri shadow_puppet -v 0.3.2
	gem install --no-rdoc --no-ri ruby-debug
}

# adds /var/lib/gems/1.8/bin to paths. only needed with the system (debian) braindead gems

function add_gems_to_system_path()
{
	log "fixing system path"
	## # default /etc/login.defs
	## ENV_SUPATH      PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
	## ENV_PATH        PATH=/usr/local/bin:/usr/bin:/bin:/usr/games
	## # default /etc/environment
	## PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
	##
	## When loggin-in over SSH /etc/environment path is active
	## When doing "su - xxx" - /etc/login.defs path is active

	etckeeper commit "before PATH update" || true

	ENV_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/var/lib/gems/1.8/bin
	USER_PATH=/usr/local/bin:/usr/bin:/bin:/usr/games:/var/lib/gems/1.8/bin
	ROOT_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/gems/1.8/bin

	cat <<-ENV >/etc/environment
PATH="$ENV_PATH"
ENV

	( rm /etc/login.defs; awk "/^\s*ENV_SUPATH/{sub(/.*/, \"ENV_SUPATH      PATH=$ROOT_PATH\")};/^\s*ENV_PATH/{sub(/.*/, \"ENV_PATH        PATH=$USER_PATH\")};{print}" > /etc/login.defs ) < /etc/login.defs

	etckeeper commit "after PATH update"
}

#########################################################
#########################################################

banner

blender_init

setup_node
setup_hostname

check_version
pin_ami_version
update_apt
setup_etckeeper
install_stuff
install_system_ruby

if [[ "${USE_SYSTEM_GEMS:-y}" == "y"  ]]; then
	install_system_rubygems
	add_gems_to_system_path
else
	install_custom_rubygems
	upgrade_rubygems
	# upstream rubygems install executables into /usr/bin so no need to fix the path
fi


gem install rdoc # needed by most gems

install_puppet

date > /etc/bootstraped_at
etckeeper commit "bootstrapped"

trap - EXIT

echo COMPLETED

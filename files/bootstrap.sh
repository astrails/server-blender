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

function is_darwin()
{
	[[ "`uname -s`" == "Darwin" ]]
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
		"Ubuntu 10.10") true;;
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

XCODE=xcode_3.2.2_and_iphone_sdk_3.2_final.dmg

function install_xcode()
{
	if [ -e /usr/bin/gcc ]; then

		log "XCODE seems to be installed"

	else

		log "Installing XCODE..."

		if [ ! -e $XCODE ]; then
			log "plase download $XCODE and place it in root's home directory"
			exit
		fi

		hdiutil mount -plist -nobrowse -readonly -mountrandom /tmp -noidme $XCODE | tee /tmp/xcode-mount.xml

		pkg_path=`cat /tmp/xcode-mount.xml | grep string | grep /tmp/ | cut '-d>' -f2 | cut '-d<' -f1`

		log "package is mounted in $pkg_path"

		installer -pkg $pkg_path/*.mpkg -target /

		hdiutil eject $pkg_path

		log "XCODE installed"

	fi
}

function set_apt_options()
{
	export DEBIAN_FRONTEND=noninteractive
	export DEBIAN_PRIORITY=critical
	APT_OPTS="-qy -o DPkg::Options::=--force-confdef -o DPkg::Options::=--force-confnew"
}

function apt_upgrade()
{
	log "apt upgrade"
	apt-get update
	apt-get upgrade $APT_OPTS
	apt-get autoremove $APT_OPTS
}

function apt_install()
{
	apt-get install $APT_OPTS "$@"
}

function setup_etckeeper()
{
	log "installing etckeeper"
	apt_install git-core etckeeper
	cp /etc/etckeeper/etckeeper.conf /etc/etckeeper/etckeeper.conf.orig
	# etckeeper comes configured for bazr. use git instead.
	(rm /etc/etckeeper/etckeeper.conf; awk "/^\s*VCS=/{sub(/.*/, \"VCS=git\")};{print}" > /etc/etckeeper/etckeeper.conf) < /etc/etckeeper/etckeeper.conf
	etckeeper init
	etckeeper commit "import during bootstrap" || true
}

function install_stuff()
{
	log "installing required packages"
	apt_install rsync build-essential zlib1g-dev libssl-dev libreadline5-dev wget bind9-host
}

function install_system_ruby()
{
	log "installing system ruby"
	apt_install ruby irb ruby-dev libopenssl-ruby
}

function install_system_rubygems()
{
	log "installing system rubygems"
	apt_install rubygems
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

function install_rubygems()
{
	if [[ "${USE_SYSTEM_GEMS:-y}" == "y"  ]]; then
		install_system_rubygems
		add_gems_to_system_path
	else
		install_custom_rubygems
		upgrade_rubygems
		# upstream rubygems install executables into /usr/bin so no need to fix the path
	fi
}

#########################################################
#########################################################

banner

blender_init

setup_node
setup_hostname

if is_darwin; then
	install_xcode
else
	check_version
	set_apt_options
	apt_upgrade
	setup_etckeeper
	install_stuff
	install_system_ruby
	install_rubygems

	etckeeper commit "bootstrapped"
fi

log "Installing some gems"
gem install --no-rdoc --no-ri rdoc # needed by most gems
gem install --no-rdoc --no-ri ruby-debug # very useful to debug manifests

date > /etc/bootstraped_at
trap - EXIT
echo COMPLETED

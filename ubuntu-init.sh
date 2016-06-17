#!/bin/bash

# Set up development environment for new installed Ubuntu.
# copyright: Han Lu <tridlh@gmail.com>

REMOTEPC="hanlu@hanlu-OptiPlex-9020"
HOMEDIR="/home/hanlu"
WORKDIR=$HOMEDIR"/work/hanlu-work"
GITDIR=$WORKDIR"/git"
ETCDIR="/etc"
APTDIR=${ETCDIR}"/apt"
aptconf="apt.conf"
tsocksconf="tsocks.conf"

REMOTEHOME=${REMOTEPC}:${HOMEDIR}
REMOTEWORK=${REMOTEPC}:${WORKDIR}
REMOTEETC=${REMOTEPC}:${ETCDIR}
REMOTEAPT=${REMOTEPC}:${APTDIR}

aptupd="sudo apt update"
aptins="sudo apt install -y"
aptdep="sudo apt build-dep -y"

#init work environment after install ubuntu
echo ""
echo "**************************************************"
echo "*                                                *"
echo "*   Set up development environment for new       *"
echo "*   installed Ubuntu:                            *"
echo "*     1. clone from a existing developing PC;    *"
echo "*     2. new install and configs.                *"
echo "*   Initializing..............................   *"
echo "*                                                *"
echo "**************************************************"
echo ""
echo "=== 1. duplicate remote environment =============="
if [ ! -d ~/bin ]; then
	scp -r ${REMOTEHOME}/bin ~
	echo "export PATH=\"~/bin/:\$PATH\"" >> ~/.bashrc
else
	echo "~/bin Exists!"
fi
mkdir -p ${WORKDIR}
if [ ! -f ${WORKDIR}/ko.sh ]; then
	ln -sv ~/bin/ko.sh ${WORKDIR}
else
	echo "ko.sh Exists!"
fi
echo ""
echo "=== 2. duplicate remote apt proxy and update ====="
scp ${REMOTEAPT}/${aptconf} ~ 
sudo mv ~/${aptconf} ${APTDIR}
$aptupd
$aptins tsocks
scp ${REMOTEETC}/${tsocksconf} ~
sudo mv ~/${tsocksconf} ${ETCDIR}
echo ""
echo "=== 3. set ssh and remote mount =================="
$aptins ssh sshfs
if [ ! -f ~/.ssh/id_rsa.pub ]; then
	cd ~/.ssh
	ssh-keygen -t rsa
	cat .ssh/id_rsa.pub | ssh ${REMOTEPC} 'cat >> .ssh/authorized_keys'
	ssh ${REMOTEPC} 'cat .ssh/id_rsa.pub' > .ssh/authorized_keys
	mount.sh
	cd -
else
	echo "~/.ssh/id_rsa.pub Exists!"
fi
echo ""
echo "=== 4. install tools and build-deps ==============="
$aptins automake build-essential libtool
$aptdep alsa-utils
$aptins xutils-dev
$aptdep xserver-xorg-dev
$aptdep unity-control-center
$aptins xserver-xorg-dev
echo ""
echo "=== 5. set vim environment ======================="
$aptins vim vim-scripts vim-doc
scp ${REMOTEHOME}/.vimrc ~
vim-addons install taglist winmanager minibufexplorer project
$aptins ctags
$aptins cscope
echo ""
echo "=== 6. set git environment ======================="
$aptins git git-email
if [ ! -f ~/.gitconfig ]; then
	git config --global --add user.name "Han Lu"
	git config --global --add user.email "tridlh@gmail.com"
	git config --global --add sendemail.smtpencrtption "none"
	git config --global --add sendemail.smtpserver "smtp.gmail.com"
	git config --global --add sendemail.smtpserverport "587"
	git config --global --add sendemail.confirm "auto"
	git config --global --add sendemail.from "tridlh@gmail.com"
else
	echo "~/.gitconfig Exists!"
fi

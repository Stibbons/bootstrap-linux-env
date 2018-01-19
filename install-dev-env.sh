#!/bin/bash

PROJECT_DIR=$HOME/Projects

if [[ -d $HOME/Projects/dev-tools ]]; then
    # Special env for work
    PROJECT_DIR=$HOME/Projects/dev-tools
fi
echo
echo "Automated installation of a new Development environment"
echo
echo "Info:"
echo "PROJECT_DIR=$PROJECT_DIR"
cat /etc/lsb-release

echo
echo "Please type your 'sudo' password:"
sudo /bin/true

echo
echo "apt-get update/upgrade"
sudo -E apt-get update -y || exit 1
sudo -E apt-get upgrade -y || exit 1

echo
echo "Installing some tools..."
sudo -E apt-get install -y vim gedit || exit 1
sudo -E apt-get install -y exuberant-ctags pandoc || exit 1
sudo -E apt-get install -y htop || exit 1
sudo -E apt-get install -y git git-gui gitk tig || exit 1
sudo -E apt-get install -y git chromium-browser || exit 1
sudo -E apt-get install -y git gconf-editor kdiff3 || exit 1
sudo -E apt-get install -y python3-pip || exit 1

echo
echo "Installing pip tools..."
pip3 install --upgrade --user pip pipenv || exit 1

(
    source /etc/lsb-release

    exit 0 # this just leave the current '(...)' block

    # Work around GNUTLS bug in Ubuntu 13.10
    if [[ DISTRIB_DESCRIPTION == "Ubuntu 13.10" ]]; then
        echo
        echo "Patching to work around bug in GNUTLS handshake..."
        echo "See: http://stackoverflow.com/questions/13524242/error-gnutls-handshake-failed-git-repository"
        sudo -E apt-get install -y build-essential fakeroot dpkg-dev
        mkdir $PROJECT_DIR/python-pycurl-openssl
        cd $PROJECT_DIR/python-pycurl-openssl
        sudo -E apt-get source -y python-pycurl
        sudo -E apt-get build-dep -y python-pycurl
        sudo -E apt-get install -y libcurl4-openssl-dev
        sudo -E dpkg-source -x pycurl_7.19.0-4ubuntu3.dsc
        cd pycurl-7.19.0
        chmod a+rw debian/patches/10_setup.py.patch setup.py debian/control
        # remove the HAVE_CURL_GNUTLS=1 in debian/patches/10_setup.py.patch
        sudo -E sed -i "s/('HAVE_CURL_GNUTLS', 1)//g" debian/patches/10_setup.py.patch

        # remove the HAVE_CURL_GNUTLS=1 in the following file
        sudo -E sed -i "s/('HAVE_CURL_GNUTLS', 1)//g" setup.py

        # replace all gnutls into openssl in the following file
        sudo -E sed -i 's/gnutls/openssl/g' debian/control
        sudo -E dpkg-buildpackage -rfakeroot -b
        sudo -E dpkg -i ../python-pycurl_7.19.0-*ubuntu8_amd64.deb
    fi
)

(
    source /etc/lsb-release

    # Work around GNUTLS bug in Ubuntu 13.10
    if [[ DISTRIB_DESCRIPTION == "Ubuntu 13.10" ]]; then
        sudo -E apt-get install -y gnome-session-fallback
    fi
)

echo
echo "Retrieving bootstrap as a project to futur updates..."
(
    mkdir -p $PROJECT_DIR/bootstrap-linux-env
    cd $PROJECT_DIR/bootstrap-linux-env
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/bootstrap-linux-env.git .

    else
        echo "Updating..."
        git fetch --all | git rebase
    fi
)

echo
echo "Installing sublime"
which subl
SUBL_VERSION=3143
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  # 64-bit stuff here
  SUBL_PLATFORM='amd64'
  SUBL_URL=https://download.sublimetext.com/sublime-text_build-${SUBL_VERSION}_amd64.deb

else
  SUBL_URL=https://download.sublimetext.com/sublime-text_build-${SUBL_VERSION}_i386.deb
  # 32-bit stuff here
  SUBL_PLATFORM='i386'
fi
if [[ $? == 1 || $(subl --version) != "Sublime Text Build $SUBL_VERSION" ]]; then
    (
        cd
        mkdir -p Downloads
        cd Downloads
        wget ${SUBL_URL} || exit 1
        sudo -E dpkg -i sublime-text_build-${SUBL_VERSION}_${SUBL_PLATFORM}.deb
    )
fi
subl --version

function install_sublime_plugin()
{
    github_project=$1
    shift
    mount_point=$1
    shift

    if [[ -d .config/sublime-text-3/Packages/$mount_point ]]; then
        rm -rfv .config/sublime-text-3/Packages/$mount_point
    fi
    cd $HOME

    mkdir -p $HOME/.config/sublime-text-3/Packages/$mount_point
    cd $HOME/.config/sublime-text-3/Packages/$mount_point/
    if [[ ! -f $PROJECT_DIR/$mount_point ]]; then
        ln -sf ~/.config/sublime-text-3/Packages/repo-config $PROJECT_DIR/$mount_point
    fi
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/$github_project.git .
    else
        echo "Updating..."
        git fetch --all | git rebase
    fi
}

echo
echo "Installing codeintel"
pip3 install --user codeintel pipenv pbr

echo
echo "Retrieving my sublime configuration..."
cd $HOME
(
    # if [[ -d .config/sublime-text-3/Packages/User ]]; then
    #     rm -rfv .config/sublime-text-3/Packages/User
    # fi
    mkdir -p .config/sublime-text-3/Packages/User
    cd $HOME/.config/sublime-text-3/Packages/User/
    if [[ ! -f $PROJECT_DIR/sublime-config ]]; then
        ln -sf ~/.config/sublime-text-3/Packages/User $PROJECT_DIR/sublime-config
    fi
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/sublime-user-config.git .
        xdg-open https://sublime.wbond.net/installation &
        subl &
    else
        echo "Updating..."
        git fetch --all | git rebase
    fi
    install_sublime_plugin 'sublime-repo' 'sublime-repo'
    install_sublime_plugin 'FastSwitch' 'sublime-fastswitch'
    install_sublime_plugin 'sublime-git-commands' 'sublime-git-commands'
    install_sublime_plugin 'sublime-text-unit-test-runner' 'sublime-text-unit-test-runner'
)

echo
echo "Installing oh-my-zsh..."
(
    mkdir -p $PROJECT_DIR/oh-my-zsh
    cd $PROJECT_DIR/oh-my-zsh
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/oh-my-zsh.git .
    else
        echo "Updating..."
        git fetch --all | git rebase
    fi
    git remote add origin          https://Stibbons@github.com/Stibbons/oh-my-zsh.git
    git remote add upstream        https://github.com/robbyrussell/oh-my-zsh.git
    ln -sf $PROJECT_DIR/oh-my-zsh $HOME/.oh-my-zsh
    if [[ ! -f $HOME/.gitconfig ]]; then
        ln -sf Projects/oh-my-zsh/dot_files/gitconfig $HOME/.gitconfig
    fi
    ln -sf $PROJECT_DIR/oh-my-zsh/templates/zshrc-linux.zsh $HOME/.zshrc
)

echo
echo "Installing zsh"
sudo -E apt-get install -y zsh || exit 1
sudo -E apt-get autoremove -y || exit 1
# password asked here
chsh -s /bin/zsh

(
    echo
    echo "Installing guake..."

    mkdir -p $PROJECT_DIR/guake
    cd $PROJECT_DIR/guake

    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/guake.git .
    else
        echo "Updating..."
        git fetch --all | git pull --rebase || exit 1
    fi
    git remote add upstream https://Stibbons@github.com/Guake/guake.git
    git fetch --all
    ln -s git-hooks/post-commit .git/hooks/

    ./autogen.sh
    make || exit 1
    sudo -E make install || exit 1
    git remote add upstream https://Stibbons@github.com/Guake/guake.git


    mkdir -p $PROJECT_DIR/guake3
    cd $PROJECT_DIR/guake3

    if [[ ! -d .git ]]; then
        git clone -b guake3 https://Stibbons@github.com/Stibbons/guake.git .
    else
        echo "Updating..."
        git fetch --all | git pull --rebase || exit 1
    fi
    git remote add -m guake3 upstream https://Stibbons@github.com/Guake/guake.git
    git fetch --all | git pull --rebase || exit 1
)

(
    echo
    echo "Installing python tools..."
    sudo -E apt-get install -y pyflakes || exit 1
    sudo -E apt-get install -y extract || exit 1
    sudo -E apt-get install -y poedit || exit 1
)

(
    echo
    echo "Installing npm..."
    sudo -E apt-get install -y npm
    npm install npm
    npm install bower
    npm install gulp
    npm install grunt
    npm install yarn
)

echo
echo "Environment successfully installed or updated."
echo "Please Reboot to enable use of guake as your favorite terminal, zsh as your master shell."

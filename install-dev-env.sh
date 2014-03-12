#!/bin/bash

PROJECT_DIR=$HOME/Projects

if [[ -d $HOME/projects/dev-tools ]]; then
    # Special env for work
    PROJECT_DIR=$HOME/projects/dev-tools
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
sudo apt-get update -y || exit 1
sudo apt-get upgrade -y || exit 1

echo
echo "Some apt..."
sudo apt-get install -y vim gedit || exit 1
sudo apt-get install -y git git-gui gitk tig || exit 1
sudo apt-get install -y git chromium-browser || exit 1

echo
echo "Installing sublime"
which subl
if [[ $? == 1 || $(subl --version) != "Sublime Text Build 3059" ]]; then
    (
        mkdir Downloads
        cd Downloads
        wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3059_amd64.deb || exit 1
        sudo dpkg -i sublime-text_build-3059_amd64.deb
    )
fi
subl --version

echo
echo "Retrieving my sublime configuration..."
cd $HOME
(
    mkdir -p .config/sublime-text-3/Packages/User
    cd .config/sublime-text-3/Packages/User/
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/sublime-user-config.git .
        firefox https://sublime.wbond.net/installation &
        subl &
    else
        echo "Updating..."
        git fetch --all
    fi
)

echo
echo "Retrieving my sublime configuration..."
(
    source /etc/lsb-release

    exit 0 # this just leave the current '(...)' block

    # Work around GNUTLS bug in Ubuntu 13.10
    # http://stackoverflow.com/questions/13524242/error-gnutls-handshake-failed-git-repository
    if [[ DISTRIB_DESCRIPTION == "Ubuntu 13.10" ]]; then
        sudo apt-get install -y build-essential fakeroot dpkg-dev
        mkdir $PROJECT_DIR/python-pycurl-openssl
        cd $PROJECT_DIR/python-pycurl-openssl
        sudo apt-get source -y python-pycurl
        sudo apt-get build-dep -y python-pycurl
        sudo apt-get install -y libcurl4-openssl-dev
        sudo dpkg-source -x pycurl_7.19.0-4ubuntu3.dsc
        cd pycurl-7.19.0
        chmod a+rw debian/patches/10_setup.py.patch setup.py debian/control
        # remove the HAVE_CURL_GNUTLS=1 in debian/patches/10_setup.py.patch
        sudo sed -i "s/('HAVE_CURL_GNUTLS', 1)//g" debian/patches/10_setup.py.patch

        # remove the HAVE_CURL_GNUTLS=1 in the following file
        sudo sed -i "s/('HAVE_CURL_GNUTLS', 1)//g" setup.py

        # replace all gnutls into openssl in the following file
        sudo sed -i 's/gnutls/openssl/g' debian/control
        sudo dpkg-buildpackage -rfakeroot -b
        sudo dpkg -i ../python-pycurl_7.19.0-*ubuntu8_amd64.deb
    fi
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
        git fetch --all
    fi
    git remote add bchretien       https://github.com/bchretien/oh-my-zsh.git
    git remote add bors-ltd        https://github.com/bors-ltd/oh-my-zsh.git
    git remote add cadusk          https://github.com/cadusk/oh-my-zsh.git
    git remote add dlintw          https://github.com/dlintw/oh-my-zsh.git
    git remote add jeroenjanssens  https://github.com/jeroenjanssens/oh-my-zsh.git
    git remote add kipanshi        https://github.com/kipanshi/oh-my-zsh.git
    git remote add origin          https://Stibbons@github.com/Stibbons/oh-my-zsh.git
    git remote add sjl             https://github.com/sjl/oh-my-zsh.git
    git remote add styx            https://github.com/styx/oh-my-zsh.git
    git remote add upstream        https://github.com/robbyrussell/oh-my-zsh.git
    git remote add ysmood          https://github.com/ysmood/oh-my-zsh.git
    ln -sf $PROJECT_DIR/oh-my-zsh $HOME/.oh-my-zsh
    if [[ ! -f $HOME/.gitconfig ]]; then
        ln -sf Projects/oh-my-zsh/dot_files/gitconfig $HOME/.gitconfig
    fi
    ln -sf $PROJECT_DIR/oh-my-zsh/templates/zshrc-linux.zsh $HOME/.zshrc
)

echo
echo "Installing zsh"
sudo apt-get install -y zsh-beta || exit 1
sudo apt-get autoremove -y || exit 1
# password asked here
chsh -s /bin/zsh

echo
echo "Installing guake..."
(
    mkdir -p $PROJECT_DIR/guake
    cd $PROJECT_DIR/guake
    sudo apt-get install -y build-essential python autoconf
    sudo apt-get install -y gnome-common gtk-doc-tools libglib2.0-dev libgtk2.0-dev libgconf2-dev
    sudo apt-get install -y python-gtk2 python-gtk2-dev python-vte python-appindicator
    sudo apt-get install -y python3-dev python-pip
    sudo apt-get install -y glade-gtk2

    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/guake.git .
        ./autogen.sh
        make
        sudo make install
    else
        echo "Updating..."
        git fetch --all
        make
        sudo make install
    fi
    git remote add upstream https://Stibbons@github.com/Guake/guake.git
)

echo
echo "Environment successfully installed or updated."
echo "Please Reboot to enable use of guake as your favorite terminal, zsh as your master shell."

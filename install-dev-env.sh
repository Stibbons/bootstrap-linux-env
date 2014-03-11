#!/bin/bash

echo "Please type your password"
sudo /bin/true

sudo apt-get install -y vim gedit || exit 1
sudo apt-get install -y git git-gui gitk tig || exit 1
sudo apt-get install -y git chromium-browser || exit 1

echo Installing sublime
which subl
if [[ $? == 1 ]]; then
    (
        mkdir Downloads
        cd Downloads
        wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3059_amd64.deb || exit 1
        sudo dpkg -i sublime-text_build-3059_amd64.deb
    )
fi

cd $HOME
(
    mkdir -p .config/sublime-text-3/Packages/User
    cd .config/sublime-text-3/Packages/User/
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/sublime-user-config.git .
        firefox https://sublime.wbond.net/installation &
        subl &
    else
        git fetch --all
    fi
)

(
    source /etc/lsb-release

    exit 0

    if [[ DISTRIB_DESCRIPTION == "Ubuntu 13.10" ]]; then
        sudo apt-get install -y build-essential fakeroot dpkg-dev
        mkdir ~/Projects/python-pycurl-openssl
        cd ~/Projects/python-pycurl-openssl
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

(
    mkdir -p Projects/oh-my-zsh
    cd Projects/oh-my-zsh
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/oh-my-zsh.git .
    else
        git fetch --all
    fi
    ln -sf $HOME?.oh-my-zsh $HOME/Projects/oh-my-zsh
    ln -sf Projects/oh-my-zsh/dot_files/gitconfig ~/.gitconfig
    ln -sf ~/Projects/oh-my-zsh/templates/zshrc-linux.zsh ~/.zshrc
)

sudo apt-get install -y zsh-beta || exit 1
# password asked here
chsh -s /bin/zsh

(
    mkdir -p Projects/guake
    cd Projects/guake
    sudo apt-get install -y build-essential python autoconf
    sudo apt-get install -y gnome-common gtk-doc-tools libglib2.0-dev libgtk2.0-dev libgconf2-dev
    sudo apt-get install -y python-gtk2 python-gtk2-dev python-vte python-appindicator
    sudo apt-get install -y python3-dev python-pip

    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/guake.git .
    else
        git fetch --all
    fi
)

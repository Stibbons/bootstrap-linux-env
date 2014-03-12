#!/bin/bash

echo "Automated installation of a new Development environment"
echo
echo "Info:"
cat /etc/lsb-release

echo "Please type your 'sudo' password:"
sudo /bin/true

echo "apt..."
sudo apt-get install -y vim gedit || exit 1
sudo apt-get install -y git git-gui gitk tig || exit 1
sudo apt-get install -y git chromium-browser || exit 1

echo "Installing sublime"
which subl
if [[ $? == 1 ]]; then
    (
        mkdir Downloads
        cd Downloads
        wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3059_amd64.deb || exit 1
        sudo dpkg -i sublime-text_build-3059_amd64.deb
    )
fi

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
        git fetch --all
    fi
)

echo "Retrieving my sublime configuration..."
(
    source /etc/lsb-release

    exit 0 # this just leave the current '(...)' block

    if [[ DISTRIB_DESCRIPTION == "Ubuntu 13.10" ]]; then
        sudo apt-get install -y build-essential fakeroot dpkg-dev
        mkdir $HOME/Projects/python-pycurl-openssl
        cd $HOME/Projects/python-pycurl-openssl
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

echo "Installing oh-my-zsh..."
(
    mkdir -p Projects/oh-my-zsh
    cd Projects/oh-my-zsh
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/oh-my-zsh.git .

    else
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
    ln -sf $HOME/Projects/oh-my-zsh $HOME/.oh-my-zsh
    ln -sf Projects/oh-my-zsh/dot_files/gitconfig $HOME/.gitconfig
    ln -sf $HOME/Projects/oh-my-zsh/templates/zshrc-linux.zsh $HOME/.zshrc
)

echo "Installing zsh"
sudo apt-get install -y zsh-beta || exit 1
# password asked here
chsh -s /bin/zsh

echo "Installing guake..."
(
    mkdir -p Projects/guake
    cd Projects/guake
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
        git fetch --all
    fi
    git remote add upstream https://Stibbons@github.com/Guake/guake.git
)

echo "Please Reboot"

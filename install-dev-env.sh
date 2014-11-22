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
echo "Installing some tools..."
sudo apt-get install -y vim gedit || exit 1
sudo apt-get install -y git git-gui gitk tig || exit 1
sudo apt-get install -y git chromium-browser || exit 1

(
    source /etc/lsb-release

    exit 0 # this just leave the current '(...)' block

    # Work around GNUTLS bug in Ubuntu 13.10
    if [[ DISTRIB_DESCRIPTION == "Ubuntu 13.10" ]]; then
        echo
        echo "Patching to work around bug in GNUTLS handshake..."
        echo "See: http://stackoverflow.com/questions/13524242/error-gnutls-handshake-failed-git-repository"
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

(
    source /etc/lsb-release

    # Work around GNUTLS bug in Ubuntu 13.10
    if [[ DISTRIB_DESCRIPTION == "Ubuntu 13.10" ]]; then
        sudo apt-get install -y gnome-session-fallback
    fi
)

echo
echo "Retrieving bootstrap as a project to futur updates..."
(
    mkdir -p $PROJECT_DIR/bootstrap-linux-env
    cd $PROJECT_DIR/bootstrap-linux-env
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/bootstrap-linx-env.git .

    else
        echo "Updating..."
        git fetch --all | git rebase
    fi
)

echo
echo "Installing sublime"
which subl
SUBL_VERSION=3065
if [[ $? == 1 || $(subl --version) != "Sublime Text Build $SUBL_VERSION" ]]; then
    (
        mkdir Downloads
        cd Downloads
        wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-${SUBL_VERSION}_amd64.deb || exit 1
        sudo dpkg -i sublime-text_build-${SUBL_VERSION}_amd64.deb
    )
fi
subl --version

echo
echo "Retrieving my sublime configuration..."
cd $HOME
(
    if [[ -d .config/sublime-text-3/Packages/User ]]; then
        rm -rfv .config/sublime-text-3/Packages/User
    fi
    mkdir -p .config/sublime-text-3/Packages/User
    cd .config/sublime-text-3/Packages/User/
    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/sublime-user-config.git .
        xdg-open https://sublime.wbond.net/installation &
        subl &
    else
        echo "Updating..."
        git fetch --all | git rebase
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
        git fetch --all | git rebase
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
    sudo apt-get install -y build-essential python autoconf || exit 1
    sudo apt-get install -y gnome-common gtk-doc-tools libglib2.0-dev libgtk2.0-dev libgconf2-dev || exit 1
    sudo apt-get install -y python-gtk2 python-gtk2-dev python-vte python-appindicator || exit 1
    sudo apt-get install -y python3-dev python-pip || exit 1
    sudo apt-get install -y glade-gtk2 || exit 1

    if [[ ! -d .git ]]; then
        git clone https://Stibbons@github.com/Stibbons/guake.git .
    else
        echo "Updating..."
        git fetch --all | git pull --rebase || exit 1
    fi
    git remote add upstream https://Stibbons@github.com/Guake/guake.git
    ./autogen.sh
    make || exit 1
    sudo make install || exit 1
    git remote add upstream https://Stibbons@github.com/Guake/guake.git
)


(
    echo
    echo "Installing python tools..."
    sudo apt-get install -y pyflakes || exit 1
    sudo apt-get install -y extract || exit 1

    echo
    echo "Installing pip tools..."
    sudo pip install percol || exit 1
    sudo pip install grin || exit 1
    sudo pip install simplejson || exit 1
    sudo pip install pylint || exit 1
    sudo pip install Twisted || exit 1
    sudo pip install Mock || exit 1
    sudo pip install simplejson || exit 1
    sudo pip install pyyaml || exit 1
    sudo pip install dictns || exit 1
    sudo pip install Sphinx || exit 1
    sudo pip install epydoc || exit 1
    sudo pip install coverage || exit 1
    sudo pip install pylint || exit 1
    sudo pip install ipdb || exit 1
    sudo pip install pep8 || exit 1
    sudo pip install autopep8 || exit 1
)

echo
echo "Environment successfully installed or updated."
echo "Please Reboot to enable use of guake as your favorite terminal, zsh as your master shell."

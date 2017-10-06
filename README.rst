bootstrap-linux-env
===================

My bootstrap script for deploying a new linux environment

How to setup::

    wget --no-check-certificate https://raw.github.com/Stibbons/bootstrap-linux-env/master/install-dev-env.sh -O - | bash

Proxy: Export the http_proxy prior to the execution of this script::

    ftp_proxy=http://...
    http_proxy=http://...
    https_proxy=http://...
    no_proxy=localhost

Note: for work environment, please create ``~/Projects/dev-tools`` before starting this script.

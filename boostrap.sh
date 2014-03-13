#!/bin/bash

echo "Getting latest version of boostrap..."
wget --no-check-certificate https://raw.github.com/stibbons/bootstrap-linux/install-dev-env.sh -O - | bash

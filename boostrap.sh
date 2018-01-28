#!/bin/bash

echo "Getting latest version of boostrap..."
wget --no-check-certificate https://raw.github.com/gsemet/bootstrap-linux-env/master/install-dev-env.sh -O - | bash

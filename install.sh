#!/bin/sh -eux
# Install swarmsim on a new ubuntu machine. Most recently tested on ubuntu 19.10.
# For ec2, first open port 9000 in the 3c2 firewall:
# - directions: http://stackoverflow.com/questions/17161345/how-to-open-a-web-server-port-on-ec2-instance
# - security group: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:sort=groupId
#
# Usage:
#
#    curl https://raw.githubusercontent.com/swarmsim/swarm/master/install.sh | sh
#

# first, all the sudo stuff.
sudo apt-get update
# node uses a separate repository.
# https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
# ruby-dev needed to build compass
sudo apt-get install -y git nodejs ruby ruby-dev phantomjs
sudo npm install -g yo generator-angular grunt-cli bower
sudo gem install compass
# updates too.
sudo npm update -g yo generator-angular grunt-cli bower
sudo npm cache verify

# check out the package and install its deps.
# assume we're running locally if the current dir is named 'swarm'.
if [ "`basename $PWD`" != "swarm" ]; then
  test -d swarm || git clone https://github.com/erosson/swarm.git
  cd swarm
fi
npm install
yes | bower install --allow-root

# everything's installed! test it.
grunt
grunt build
grunt test
# `grunt serve` to run on port 9000.

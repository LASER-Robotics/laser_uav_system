#!/bin/bash

sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
cat /etc/apt/sources.list.d/gazebo-stable.list
deb http://packages.osrfoundation.org/gazebo/ubuntu-stable bionic main
wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -

sudo apt-get update
sudo apt-get install gazebo11
sudo apt-get install libgazebo11-dev

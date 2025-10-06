#!/bin/bash

curl -sSL http://get.gazebosim.org | sh
sudo apt install ros-humble-gazebo* -y

if [ $(grep -c "/usr/share/gazebo/setup.bash" ~/.bashrc) -ne 1 ]; then
  source /opt/ros/humble/setup.bash && echo -e "\n# source Gazebo\nsource /usr/share/gazebo/setup.bash" >> ~/.bashrc
fi


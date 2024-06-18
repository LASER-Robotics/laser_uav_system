#!/bin/bash

# Install ROS Humble and Gazebo garden
cd ./enviroment_install

if ! ls "/opt" | grep -q "ros"; then
  ./install_ros_humble.sh
fi

if ! ls "/opt/ros" | grep -q "humble"; then
  ./install_ros_humble.sh
fi

if [ $(grep -c "REAL_UAV=True" ~/.bashrc) -ne 1 ]; then
  if ! ls "/usr/bin" | grep -q "gazebo"; then
    ./install_gazebo.sh
  fi
fi

# Install dep and packages
sudo apt install pip
pip3 install kconfiglib
sudo pip3 install --upgrade gitman

cd ~/git/laser_uav_system
gitman install --force

# Create workspace and create symbolic link for dirs
cd ~
mkdir laser_uav_system_ws
cd ~/laser_uav_system_ws
mkdir src
cd src

ln -sf ~/git/laser_uav_system/ros_packages/* ./

mkdir px4_packages
mv micro_xrce_dds_agent ./px4_packages
mv px4_msgs ./px4_packages
mv px4_firmware ./px4_packages

# Configure simulation and px4
./laser_uav_simulation/install.sh

# Make package with comunication protocol
cd ~/git/laser_uav_system/ros_packages/micro_xrce_dds_agent
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig /usr/local/lib/

# Build workspace
cd ~/laser_uav_system_ws
sudo rosdep init 
rosdep update
rosdep install -i --from-path src --rosdistro humble -y
colcon build --symlink-install --packages-skip px4 microxrcedds_agent 

if [ $(grep -c "~/laser_uav_system_ws/install/setup.bash" ~/.bashrc) -ne 1 ]; then
  source ~/laser_uav_system_ws/install/setup.bash && echo -e "\n\n#source laser_uav_system workspace \nsource ~/laser_uav_system_ws/install/setup.bash" >> ~/.bashrc
fi

sudo apt install toilet

toilet laser
toilet uav
toilet system 
toilet installed

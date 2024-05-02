#!/bin/bash

#Install ROS Humble and Gazebo garden
cd ./enviroment_install

if ! ls "/opt" | grep -q "ros"; then
  ./install_ros_humble.sh
fi

if ! ls "/opt/ros" | grep -q "humble"; then
  ./install_ros_humble.sh
fi

if ! ls "/usr/bin" | grep -q "gazebo"; then
  ./install_gazebo.sh
fi

#Install dep and packages
pip3 install kconfiglib
pip3 install --upgrade gitman

cd ~/git/laser_uav_system/.gitman/
git clone git@github.com:PX4/PX4-Autopilot.git -b release/1.14 --recursive 
cd PX4-Autopilot
cd ~/git/laser_uav_system/ros_packages/
ln -sf ~/git/laser_uav_system/.gitman/PX4-Autopilot ./

cd ../
gitman install

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
mv PX4-Autopilot ./px4_packages

# Set configs of PX4
cd ~/git/laser_uav_system/ros_packages/PX4-Autopilot
bash ./Tools/setup/ubuntu.sh
make px4_sitl

# Make package with comunication protocol
cd ~/laser_uav_system_ws/src/micro_xrce_dds_agent
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
colcon build --packages-skip px4 

if [ $(grep -c "~/laser_uav_system_ws/install/setup.bash" ~/.bashrc) -ne 1 ]; then
  source ~/laser_uav_system_ws/install/setup.bash && echo -e "\n\n#source laser_uav_system workspace \nsource ~/laser_uav_system_ws/install/setup.bash" >> ~/.bashrc
fi

toilet laser
toilet uav
toilet system 
toilet installed

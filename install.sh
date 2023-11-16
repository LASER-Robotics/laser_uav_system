# Install ROS Humble and Gazebo garden
cd ./enviroment_install
./install_ros_humble.sh
./install_gazebo.sh

# Install dep and packages
pip3 install kconfiglib
pip3 install --upgrade gitman

cd ../
gitman install

cd ~/git/laser_uav_system/ros_packages/
git clone https://github.com/PX4/PX4-Autopilot.git --recursive

# Create workspace and create symbolic link for dirs
cd ~
mkdir laser_uav_system_ws
cd ~/laser_uav_system_ws
mkdir src
cd src

ln -sf ~/git/laser_uav_system/ros_packages/* ./

# Set configs of PX4
cd ~/git/laser_uav_system/ros_packages/PX4-Autopilot
bash ./Tools/setup/ubuntu.sh

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

if [ $(grep -c "~/laser_uav_system_ws/install/setup.bash" ~/.bashrc) -ne 1 ]; then
  source ~/laser_uav_system_ws/install/setup.bash && echo -e "\n\n#source laser_uav_system workspace \nsource ~/laser_uav_system_ws/install/setup.bash" >> ~/.bashrc
fi

toilet laser
toilet uav
toilet system 
toilet installed

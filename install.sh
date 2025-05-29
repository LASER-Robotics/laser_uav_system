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
pip install packaging==24.2
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

rm micro_xrce_dds_agent
rm px4_firmware

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
colcon build --symlink-install

if [ $(grep -c "~/laser_uav_system_ws/install/setup.bash" ~/.bashrc) -ne 1 ]; then
  source ~/laser_uav_system_ws/install/setup.bash && echo -e "\n\n#source laser_uav_system workspace \nsource ~/laser_uav_system_ws/install/setup.bash" >> ~/.bashrc
fi

if [ $(grep -c "uav_name" ~/.bashrc) -ne 1 ]; then
  resp=""
  [[ -t 0 ]] && { read -p $'\e[1;32mWhat the uav name :\e[0m\n' resp ; }
  echo -e "export uav_name=\""$resp"\"" >> ~/.bashrc
fi

if [ $(grep -c "uav_type" ~/.bashrc) -ne 1 ]; then
  resp=""
  [[ -t 0 ]] && { read -p $'\e[1;32mWhat the uav type :\e[0m\n' resp ; }
  echo -e "export uav_type=\""$resp"\"" >> ~/.bashrc
fi

# Acados installation solver of nmpc
cd ~/laser_uav_system_ws/src/laser_uav_controllers/
git submodule update --recursive --init
cd acados
git submodule update --recursive --init
mkdir -p build
cd build
cmake -DACADOS_WITH_QPOASES=ON ..
make install -j4

if [ $(grep -c "ACADOS_SOURCE_DIR" ~/.bashrc) -ne 1 ]; then
  echo -e "#set acados solver of nmpc \nexport ACADOS_SOURCE_DIR="~/laser_uav_system_ws/src/laser_uav_controllers/acados"" >> ~/.bashrc
  echo -e "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:"~/laser_uav_system_ws/src/laser_uav_controllers/acados/lib"" >> ~/.bashrc
fi

sudo apt install toilet

toilet laser
toilet uav
toilet system 
toilet installed

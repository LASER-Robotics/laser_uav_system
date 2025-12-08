#!/bin/bash

if [ "${GITHUB_ACTIONS}" == "true" ]; then
    BASE_DIR="$GITHUB_WORKSPACE"
else
    BASE_DIR="$HOME"
fi

set -e

if [ -z "$REAL_UAV" ]; then
  resp=""
  [[ -t 0 ]] && { read -p $'\e[1;32mThis is a real uav? (true, false):\e[0m\n' resp ; }
  echo -e "export REAL_UAV=\""$resp"\"" >> ~/.bashrc
  source ~/.bashrc
fi

# Install ROS Humble and Gazebo garden
 cd ./environment_install
 
 ./install_ros_humble.sh

if [ "$REAL_UAV" == "\"false\"" ]; then
  if ! ls "/usr/bin" | grep -q "gazebo"; then
    ./install_gazebo.sh
    sudo apt install ros-humble-gazebo-* -y
  fi
fi

 if [ $(grep -c "MAKEFLAGS" ~/.bashrc) -ne 1 ]; then
   export MAKEFLAGS=-j4 && echo -e "export MAKEFLAGS=-j4" >> ~/.bashrc
 fi

# Install dep and packages
sudo apt-get update
sudo apt install pip -y
pip install packaging==24.2
pip3 install kconfiglib jsonschema pyros future empy==3.3.4 pyros-genmsg setuptools
sudo pip3 install --upgrade gitman
sudo apt install ros-humble-mavlink* -y
sudo apt install ros-humble-pcl* -y
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good libunwind-dev

cd $BASE_DIR/git/laser_uav_system

if [ "$REAL_UAV" == "\"false\"" ]; then
  gitman install simulation --force
else
  gitman install real --force
fi

# Create workspace and create symbolic link for dirs
cd $BASE_DIR
mkdir laser_uav_system_ws
cd $BASE_DIR/laser_uav_system_ws
mkdir src
cd src

ln -sf $BASE_DIR/git/laser_uav_system/ros_packages/* ./

if [ "$REAL_UAV" == "\"false\"" ]; then
  cd laser_uav_simulation/scripts
  ./build_px4_firmware.sh
  cd $BASE_DIR/laser_uav_system_ws/src
  rm px4_firmware
fi

rm micro_xrce_dds_agent
# Make package with comunication protocol
cd $BASE_DIR/git/laser_uav_system/ros_packages/micro_xrce_dds_agent
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig /usr/local/lib/

if [ "$REAL_UAV" == "\"true\"" ]; then
  if [ -z "$UAV_NAME" ]; then
    resp=""
    [[ -t 0 ]] && { read -p $'\e[1;32mWhat the uav name (ex: uav1, uav2, uav3, ...):\e[0m\n' resp ; }
    echo -e "export UAV_NAME=\""$resp"\"" >> ~/.bashrc
  fi

  if [ -z "$UAV_TYPE" ]; then
    resp=""
    [[ -t 0 ]] && { read -p $'\e[1;32mWhat the uav type (ex: x500, lr7pro, ...):\e[0m\n' resp ; }
    echo -e "export UAV_TYPE=\""$resp"\"" >> ~/.bashrc
  fi

  if [ "${GITHUB_ACTIONS}" == "true" ]; then
    $BASE_DIR/git/laser_uav_system/environment_install/install_realsense_sdk.sh
    $BASE_DIR/git/laser_uav_system/environment_install/install_livox_sdk.sh
  else
   # realsense sdk installation
   default=n
   while true; do
     if [[ "$unattended" == "1" ]]
     then
       resp=$default
     else
       [[ -t 0 ]] && { read -t 10 -n 2 -p $'\e[1;32mInstall Realsense Series SDK? [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default ; }
     fi
     response=`echo $resp | sed -r 's/(.*)$/\1=/'`
  
     if [[ $response =~ ^(y|Y)=$ ]] 
     then
       $BASE_DIR/git/laser_uav_system/environment_install/install_realsense_sdk.sh
       break
     elif [[ $response =~ ^(n|N)=$ ]] 
     then
       break
     else
       echo " What? \"$resp\" is not a correct answer."
     fi
   done
  
   # livox sdk installation
   default=n
   while true; do
     if [[ "$unattended" == "1" ]]
     then
       resp=$default
     else
       [[ -t 0 ]] && { read -t 10 -n 2 -p $'\e[1;32mInstall Livox Series SDK? [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default ; }
     fi
     response=`echo $resp | sed -r 's/(.*)$/\1=/'`
  
     if [[ $response =~ ^(y|Y)=$ ]] 
     then
       $BASE_DIR/git/laser_uav_system/environment_install/install_livox_sdk.sh
       break
     elif [[ $response =~ ^(n|N)=$ ]] 
     then
       break
     else
       echo " What? \"$resp\" is not a correct answer."
     fi
   done
  fi
 fi

 # Acados installation solver of nmpc
 cd $BASE_DIR/laser_uav_system_ws/src/laser_uav_controllers/
 git submodule update --recursive --init
 cd acados
 git submodule update --recursive --init
 mkdir -p build
 cd build
 cmake -DACADOS_WITH_QPOASES=ON ..
 make install -j4

 if [ $(grep -c "ACADOS_SOURCE_DIR" ~/.bashrc) -ne 1 ]; then
   export ACADOS_SOURCE_DIR="$BASE_DIR/laser_uav_system_ws/src/laser_uav_controllers/acados" && echo -e "#set acados solver of nmpc \nexport ACADOS_SOURCE_DIR="~/laser_uav_system_ws/src/laser_uav_controllers/acados"" >> ~/.bashrc
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$BASE_DIR/laser_uav_system_ws/src/laser_uav_controllers/acados/lib" && echo -e "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:"~/laser_uav_system_ws/src/laser_uav_controllers/acados/lib"" >> ~/.bashrc
 fi

 if [ $(grep -c "GAZEBO_PLUGIN_PATH" ~/.bashrc) -ne 1 ]; then
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$BASE_DIR/git/laser_uav_system/ros_packages/px4_firmware/build/px4_sitl_default/build_gazebo-classic" && echo -e "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:"~/git/laser_uav_system/ros_packages/px4_firmware/build/px4_sitl_default/build_gazebo-classic"" >> ~/.bashrc
   export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH$BASE_DIR/git/laser_uav_system/ros_packages/px4_firmware/build/px4_sitl_default/build_gazebo-classic && echo -e "export GAZEBO_PLUGIN_PATH=\$GAZEBO_PLUGIN_PATH~/git/laser_uav_system/ros_packages/px4_firmware/build/px4_sitl_default/build_gazebo-classic" >> ~/.bashrc
   export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$BASE_DIR/git/laser_uav_system/ros_packages/px4_firmware/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models:$BASE_DIR/git/laser_uav_system/ros_packages/laser_uav_simulation/models:$BASE_DIR/git/laser_uav_system/ros_packages/laser_uav_simulation/core/models && echo -e "export GAZEBO_MODEL_PATH=\$GAZEBO_MODEL_PATH:~/git/laser_uav_system/ros_packages/px4_firmware/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models:~/git/laser_uav_system/ros_packages/laser_uav_simulation/models:~/git/laser_uav_system/ros_packages/laser_uav_simulation/core/models" >> ~/.bashrc
 fi

 # Autodiff for EKF
 cd $BASE_DIR/laser_uav_system_ws/src/laser_uav_estimators/
 git submodule update --recursive --init
 cd autodiff
 mkdir -p build
 cd build
 cmake -DAUTODIFF_BUILD_TESTS=OFF -DAUTODIFF_BUILD_PYTHON=OFF ..
 sudo make install -j4

 source ~/.bashrc

 # Ceres solver for Open Vins
 sudo apt-get install ros-humble-ros2bag ros-humble-rosbag2* -y
 sudo apt-get install libeigen3-dev libboost-all-dev libceres-dev -y

 source ~/.bashrc

 # Build workspace
 cd $BASE_DIR/laser_uav_system_ws
 colcon build --symlink-install --cmake-args -Wno-dev

 if [ $(grep -c "source ~/laser_uav_system_ws/install/setup.bash" ~/.bashrc) -ne 1 ]; then
  source $BASE_DIR/laser_uav_system_ws/install/setup.bash && echo -e "\n\n#source laser_uav_system workspace \nsource ~/laser_uav_system_ws/install/setup.bash" >> ~/.bashrc
 fi

 sudo apt install toilet

 toilet laser
 toilet uav
 toilet system 
 toilet installed

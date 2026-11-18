#!/bin/bash

if [ "${GITHUB_ACTIONS}" == "true" ]; then
  BASE_DIR="$GITHUB_WORKSPACE"
  FALSE="\"false\""
  TRUE="\"true\""
  set -e
else
  BASE_DIR="$HOME"
  FALSE="false"
  TRUE="true"
fi

# Use half of available CPU cores to prevent system freeze during heavy builds
BUILD_CORES=$(($(nproc) / 2))
[[ $BUILD_CORES -lt 1 ]] && BUILD_CORES=1

# Helper function for interactive [y/n] prompts with timeout
ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local resp=$default

  while true; do
    if [[ "$unattended" == "1" ]]; then
      resp=$default
    else
      [[ -t 0 ]] && { read -t 10 -n 1 -p $'\e[1;32m'"$prompt"' [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default; }
    fi

    resp="${resp,,}"
    resp="${resp//[^yn]/}"

    if [[ "$resp" == "y" ]]; then
      return 0
    elif [[ "$resp" == "n" || -z "$resp" ]]; then
      return 1
    else
      echo " What? \"$resp\" is not a correct answer."
    fi
  done
}

# Check for active swap space and warn before heavy builds
check_swap() {
  local mem_total_kb swap_total_kb ram_gb_display target_mem_gb swap_needed_gb
  mem_total_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
  swap_total_kb=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)
  mem_total_kb=${mem_total_kb:-0}
  swap_total_kb=${swap_total_kb:-0}

  if [[ "$swap_total_kb" -eq 0 ]]; then
    ram_gb_display=$(awk -v kb="$mem_total_kb" 'BEGIN { printf "%.1f", kb / 1048576.0 }')
    target_mem_gb=$((4 + 2 * BUILD_CORES))
    [[ $target_mem_gb -lt 16 ]] && target_mem_gb=16
    swap_needed_gb=$(awk -v target="$target_mem_gb" -v kb="$mem_total_kb" '
      BEGIN {
        diff = target - (kb / 1048576.0);
        needed = int(diff);
        if (diff > needed) needed += 1;
        if (needed < 4) needed = 4;
        print needed;
      }')

    echo -e "\e[1;33m[WARNING] No active swap space detected (SwapTotal: 0.0 GB, RAM: ${ram_gb_display} GB, BUILD_CORES: ${BUILD_CORES}).\e[0m"
    echo -e "\e[1;33mHeavy C++ builds (colcon / PX4 / Acados / OpenVINS / SUPER) can exhaust RAM and freeze or crash the system (OOM kill).\e[0m"
    echo ""
    echo "Swap estimation equation:"
    echo "  Target_Mem_GB = max(16, 4 + 2 * BUILD_CORES)   [= ${target_mem_gb} GB for ${BUILD_CORES} build cores]"
    echo "  Swap_Needed_GB = max(4, Target_Mem_GB - RAM_GB) [= ${swap_needed_gb} GB for this machine]"
    echo ""
    echo "To create and enable a ${swap_needed_gb}G swapfile before continuing (run in another terminal or abort):"
    echo "  sudo fallocate -l ${swap_needed_gb}G /swapfile"
    echo "  sudo chmod 600 /swapfile"
    echo "  sudo mkswap /swapfile"
    echo "  sudo swapon /swapfile"
    echo "  # Optional (persist across reboots):"
    echo "  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab"
    echo ""

    if [ "${GITHUB_ACTIONS}" != "true" ]; then
      if ! ask_yes_no "Continue installation without swap?" "n"; then
        echo -e "\e[1;31mInstallation aborted. Create swap space and re-run ./install.sh.\e[0m"
        exit 1
      fi
    fi
  fi
}

check_swap

if [ -z "$REAL_UAV" ]; then
  resp=""
  [[ -t 0 ]] && { read -p $'\e[1;32mThis is a real uav? (true, false):\e[0m\n' resp; }
  echo 'export REAL_UAV="'"$resp"'"' >> ~/.bashrc
  source ~/.bashrc
fi

# Install ROS Humble and Gazebo
cd ./environment_install
./install_ros_humble.sh

if [ "$REAL_UAV" == $FALSE ]; then
  if ! command -v gazebo &> /dev/null; then
    ./install_gazebo.sh
    sudo apt install ros-humble-gazebo-* -y
  fi
fi

if ! grep -q "MAKEFLAGS" ~/.bashrc; then
  export MAKEFLAGS="-j$BUILD_CORES"
  echo "export MAKEFLAGS=\"-j$BUILD_CORES\"" >> ~/.bashrc
fi

# Install system dependencies and Python packages
sudo apt-get update
sudo apt-get install -y \
  pip \
  ros-humble-mavlink* \
  ros-humble-pcl* \
  ros-humble-tf2-sensor-msgs \
  ros-humble-micro-ros-msgs* \
  ros-humble-ros2bag ros-humble-rosbag2* \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
  libunwind-dev libdw-dev libyaml-cpp-dev \
  libeigen3-dev libboost-all-dev libceres-dev \
  toilet

pip install packaging==24.2
pip3 install kconfiglib jsonschema pyros future empy==3.3.4 pyros-genmsg setuptools
sudo pip3 install --upgrade gitman

cd "$BASE_DIR/git/laser_uav_system"

fcu_type=""
if [ "$REAL_UAV" == $FALSE ]; then
  if [ "${GITHUB_ACTIONS}" == "true" ]; then
    gitman install simulation $FCU --force
    fcu_type=$FCU
  else
    [[ -t 0 ]] && while true; do
      read -p $'\e[1;32mWhat do you want to install? (px4 / ap / px4 ap):\e[0m ' fcu_type
      fcu_type="${fcu_type,,}"

      if [[ "$fcu_type" == "px4" || "$fcu_type" == "ap" || "$fcu_type" == "px4 ap" ]]; then
        gitman install simulation $fcu_type --force
        break
      else
        echo -e "\e[1;31mInvalid option! Please enter only 'px4', 'ap', or 'px4 ap'.\e[0m"
      fi
    done
  fi
else
  gitman install real --force
fi

# Create ROS workspace and symlink packages
cd "$BASE_DIR"
mkdir -p laser_uav_system_ws/src
cd "$BASE_DIR/laser_uav_system_ws/src"

ln -sf "$BASE_DIR/git/laser_uav_system/ros_packages/"* ./

# Build firmware and DDS tools for simulation
if [ "$REAL_UAV" == $FALSE ]; then
  if [[ "$fcu_type" == "px4" || "$fcu_type" == "px4 ap" ]]; then
    (cd laser_uav_simulation/scripts && ./build_px4_firmware.sh)
    rm -rf px4_firmware
  fi

  if [[ "$fcu_type" == "ap" || "$fcu_type" == "px4 ap" ]]; then
    pip3 install mavproxy
    (cd micro_xrce_dds_gen && ./gradlew assemble)

    # Add microxrceddsgen to PATH instead of symlinking to /usr/local/bin
    DDS_GEN_PATH="$BASE_DIR/git/laser_uav_system/ros_packages/micro_xrce_dds_gen/scripts"
    export PATH="$PATH:$DDS_GEN_PATH"
    if [ "${GITHUB_ACTIONS}" == "true" ]; then
      echo "$DDS_GEN_PATH" >> "$GITHUB_PATH"
    elif ! grep -q "micro_xrce_dds_gen/scripts" ~/.bashrc; then
      echo 'export PATH="$PATH:'"$DDS_GEN_PATH"'"' >> ~/.bashrc
    fi
    (cd ap_firmware && ./waf configure --disable-Werror --enable-DDS)

    rm -rf micro_xrce_dds_gen
  fi
fi

rm -rf micro_xrce_dds_agent

# Build and install Micro-XRCE-DDS Agent
(
  cd "$BASE_DIR/git/laser_uav_system/ros_packages/micro_xrce_dds_agent"
  mkdir -p build
  cd build
  cmake ..
  make -j$BUILD_CORES
  sudo make install
)
sudo ldconfig /usr/local/lib/

# Configure real UAV hardware drivers and environment
if [ "$REAL_UAV" == $TRUE ]; then
  if [ -z "$UAV_NAME" ]; then
    resp=""
    [[ -t 0 ]] && { read -p $'\e[1;32mWhat the uav name (ex: uav1, uav2, uav3, ...):\e[0m\n' resp; }
    echo 'export UAV_NAME="'"$resp"'"' >> ~/.bashrc
  fi

  if [ -z "$UAV_TYPE" ]; then
    resp=""
    [[ -t 0 ]] && { read -p $'\e[1;32mWhat the uav type (ex: x500, lr7pro, ...):\e[0m\n' resp; }
    echo 'export UAV_TYPE="'"$resp"'"' >> ~/.bashrc
  fi

  if [ "${GITHUB_ACTIONS}" == "true" ]; then
    "$BASE_DIR/git/laser_uav_system/environment_install/install_realsense_sdk.sh"
    "$BASE_DIR/git/laser_uav_system/environment_install/install_livox_sdk.sh"
    "$BASE_DIR/git/laser_uav_system/environment_install/install_lx_camera_sdk.sh"
  else
    if ask_yes_no "Install Realsense Series SDK?"; then
      "$BASE_DIR/git/laser_uav_system/environment_install/install_realsense_sdk.sh"
    fi

    if ask_yes_no "Install Livox Series SDK?"; then
      "$BASE_DIR/git/laser_uav_system/environment_install/install_livox_sdk.sh"
    fi

    if ask_yes_no "Install LX Camera S Series SDK?"; then
      "$BASE_DIR/git/laser_uav_system/environment_install/install_lx_camera_sdk.sh"
    fi
  fi
fi

# Build and install Acados NMPC solver
cd "$BASE_DIR/laser_uav_system_ws/src/laser_uav_controllers/"
git submodule update --recursive --init
cd acados
git submodule update --recursive --init
mkdir -p build
cd build
cmake -DACADOS_WITH_QPOASES=ON ..
make install -j$BUILD_CORES

if ! grep -q "ACADOS_SOURCE_DIR" ~/.bashrc; then
  export ACADOS_SOURCE_DIR="$BASE_DIR/laser_uav_system_ws/src/laser_uav_controllers/acados"
  echo -e "\n#set acados solver of nmpc \nexport ACADOS_SOURCE_DIR=\"$ACADOS_SOURCE_DIR\"" >> ~/.bashrc
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$ACADOS_SOURCE_DIR/lib"
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"'"$ACADOS_SOURCE_DIR"'/lib"' >> ~/.bashrc
fi

# Configure Gazebo environment variables
if ! grep -q "GAZEBO_PLUGIN_PATH" ~/.bashrc; then
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$BASE_DIR/git/laser_uav_system/ros_packages/px4_firmware/build/px4_sitl_default/build_gazebo-classic"
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"'$BASE_DIR'/git/laser_uav_system/ros_packages/px4_firmware/build/px4_sitl_default/build_gazebo-classic"' >> ~/.bashrc

  export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:"$BASE_DIR/git/laser_uav_system/ros_packages/px4_firmware/build/px4_sitl_default/build_gazebo-classic"
  echo 'export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:"'$BASE_DIR'/git/laser_uav_system/ros_packages/px4_firmware/build/px4_sitl_default/build_gazebo-classic"' >> ~/.bashrc

  export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:"$BASE_DIR/git/laser_uav_system/ros_packages/px4_firmware/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models:$BASE_DIR/git/laser_uav_system/ros_packages/laser_uav_simulation/models:$BASE_DIR/git/laser_uav_system/ros_packages/laser_uav_simulation/core/models"
  echo 'export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:"'$BASE_DIR'/git/laser_uav_system/ros_packages/px4_firmware/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models:'$BASE_DIR'/git/laser_uav_system/ros_packages/laser_uav_simulation/models:'$BASE_DIR'/git/laser_uav_system/ros_packages/laser_uav_simulation/core/models"' >> ~/.bashrc
fi

source ~/.bashrc

# Build ROS workspace
cd "$BASE_DIR/laser_uav_system_ws"
colcon build --symlink-install --parallel-workers $BUILD_CORES \
  --cmake-args -DCMAKE_C_FLAGS="-Wno-error" -DCMAKE_CXX_FLAGS="-Wno-error" -Wno-dev

if ! grep -q "source ~/laser_uav_system_ws/install/setup.bash" ~/.bashrc; then
  source "$BASE_DIR/laser_uav_system_ws/install/setup.bash"
  echo -e "\n\n#source laser_uav_system workspace \nsource ~/laser_uav_system_ws/install/setup.bash" >> ~/.bashrc
fi

sudo apt install -y toilet

toilet laser
toilet uav
toilet system
toilet installed

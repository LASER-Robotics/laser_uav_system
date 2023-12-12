#!/bin/bash

#Install ROS2 Humble
sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update && sudo apt upgrade -y
sudo apt install ros-humble-desktop -y
sudo apt install ros-dev-tools -y

sudo apt install python3-colcon-clean -y

sudo apt install python3-colcon-common-extensions
sudo apt install ros-humble-eigen3-cmake-module

pip install --user -U empy pyros-genmsg setuptools

if [ $(grep -c "/opt/ros/humble/setup.bash" ~/.bashrc) -ne 1 ]; then
  source /opt/ros/humble/setup.bash && echo -e "\n# source ROS Humble\n source /opt/ros/humble/setup.bash" >> ~/.bashrc
fi

if [ $(grep -c "COLCON_LOG_LEVEL" ~/.bashrc) -ne 1 ]; then
  echo -e "# reduce colcon spam\n export COLCON_LOG_LEVEL=30" >> ~/.bashrc
fi

if [ $(grep -c "RCUTILS_COLORIZED_OUTPUT" ~/.bashrc) -ne 1 ]; then
  echo -e "# make logs colorful\n export RCUTILS_COLORIZED_OUTPUT=1" >> ~/.bashrc
fi

if [ $(grep -c "RCUTILS_LOGGING_BUFFERED_STREAM" ~/.bashrc) -ne 1 ]; then
  echo -e "# force logging output to be buffered\n export RCUTILS_LOGGING_BUFFERED_STREAM=1" >> ~/.bashrc
fi

if [ $(grep -c "RCUTILS_CONSOLE_OUTPUT_FORMAT" ~/.bashrc) -ne 1 ]; then
  echo -e "# format logs in terminal\n export RCUTILS_CONSOLE_OUTPUT_FORMAT='[{severity}] [{time}] [{name}]: {message} ({function_name}() at {file_name}:{line_number})'" >> ~/.bashrc
fi

if [ $(grep -c "PYTHONWARNINGS" ~/.bashrc) -ne 1 ]; then
  echo -e "# reduce depraction warning spam in colcon\n export PYTHONWARNINGS='ignore:::setuptools.command.install,ignore:::setuptools.command.easy_install,ignore:::pkg_resources'" >> ~/.bashrc
fi

if [ $(grep -c "ROS_DOMAIN_ID" ~/.bashrc) -ne 1 ]; then
  resp=0
  [[ -t 0 ]] && { read -p $'\e[1;32mChoice a number between 46 and 232 for ROS domain ID :\e[0m\n' resp ; }
  echo -e "# always set ROS domain id\n export ROS_DOMAIN_ID="$resp"" >> ~/.bashrc
fi

if [ $(grep -c "ROS_LOCALHOST_ONLY" ~/.bashrc) -ne 1 ]; then
  echo -e "# always set ROS localhost only\n export ROS_LOCALHOST_ONLY=0" >> ~/.bashrc
fi

if [ $(grep -c "RCUTILS_LOGGING_BUFFERED_STREAM" ~/.bashrc) -ne 1 ]; then
  source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash && echo -e "# colcon tab completion\n source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
fi

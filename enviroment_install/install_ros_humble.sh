#!/bin/bash

#Install ROS2 Humble
sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo apt update && sudo apt install curl -y
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" # If using Ubuntu derivates use $UBUNTU_CODENAME
sudo dpkg -i /tmp/ros2-apt-source.deb
sudo apt update -y
sudo apt upgrade -y
sudo apt install ros-humble-desktop -y
sudo apt install ros-dev-tools -y

sudo apt install python3-colcon-clean -y

sudo apt install python3-colcon-common-extensions -y
sudo apt install ros-humble-eigen3-cmake-module -y

pip install --user -U empy==3.3.4 pyros-genmsg setuptools
pip install -U colcon-common-extensions

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

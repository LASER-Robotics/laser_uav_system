sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
sudo apt-get update
sudo apt-get install gz-garden

pip3 install --upgrade gitman

gitman install

cd ~
mkdir laser_uav_system_ws
cd ~/laser_uav_system_ws
mkdir src
cd src

ln -sf ~/git/laser_uav_system/ros_packages/* ./

cd ~/git/laser_uav_system/ros_packages/px4_autopilot
bash ./Tools/setup/ubuntu.sh

cd ~/laser_uav_system_ws
sudo rosdep init
rosdep update
rosdep install -i --from-path src --rosdistro humble -Y
colcon build

source ~/laser_uav_system_ws/install/setup.bash && echo "source ~/laser_uav_system/install/setup.bash" >> .bashrc



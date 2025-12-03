if [ "${GITHUB_ACTIONS}" == "true" ]; then
    BASE_DIR="$GITHUB_WORKSPACE"
else
    BASE_DIR="$(pwd)"
fi

sudo apt install ros-humble-diagnostic-updater
sudo chmod +x $BASE_DIR/laser_uav_system_ws/src/laser_uav_drivers/ros_packages/realsense_drivers/scripts/libuvc_installation.sh
$BASE_DIR/laser_uav_system_ws/src/laser_uav_drivers/ros_packages/realsense_drivers/scripts/libuvc_installation.sh

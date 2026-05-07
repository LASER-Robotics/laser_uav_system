# LASER UAV System [LUS]

[![Simulation Build](https://github.com/LASER-Robotics/laser_uav_system/actions/workflows/simulation-build.yml/badge.svg)](https://github.com/LASER-Robotics/laser_uav_system/actions/workflows/simulation-build.yml)
[![Real Build](https://github.com/LASER-Robotics/laser_uav_system/actions/workflows/real-build.yml/badge.svg)](https://github.com/LASER-Robotics/laser_uav_system/actions/workflows/real-build.yml)
[![License: BSD3](https://img.shields.io/badge/License-BSD3-white.svg)](https://opensource.org/licenses/BSD3)


This is the **metapackage repository** responsible for orchestrating and managing all constituent packages of the **[LUS]** autonomous drone system.

This repository does not contain functional source code itself, but rather the package structure and dependencies that define the entire system architecture. It serves as the primary entry point for cloning, installing, and executing the project's ecosystem.

---

## System Overview

The **[LUS]** is an open-source software platform designed to enable the **autonomous operation of Unmanned Aerial Vehicles (UAVs)**. The system features a modular architecture built upon **ROS 2 (Robot Operating System)**, divided into distinct packages, each responsible for a specific core functionality:

* **Perception & State Estimation:** Sensor data processing, filtering, and state estimation (e.g., VIO, LIO).
* **Planning:** Trajectory generation, motion planning, and mission planning capabilities.
* **Control:** High-level and low-level flight control algorithms.
* **Hardware API:** Interface for robust communication with the flight controller (autopilot).
* **Simulation:** Environments, models, and resources for comprehensive testing in Gazebo Classic simulation.

### Architecture

![Diagram of the LUS System Architecture, illustrating the modularity and dependencies of the ROS 2 packages.](https://github.com/LASER-Robotics/laser_uav_system/blob/stable/assets/system_architecture.png)

[Image of LUS system architecture diagram]

This metapackage ensures that all system components are installed and built with the correct version dependencies. 

---

## Getting Started

Follow these instructions to acquire and run a copy of the project on your local machine for both development and testing purposes.

### Prerequisites

Ensure the following software is installed on your system:

* **Operating System:** Ubuntu 22.04 (Jammy)
* **Version Control:** Git

### Installation

We strongly recommend utilizing our custom Linux setup for optimized system usability. To install the setup along with the **[LUS]** system, copy and paste the command below into your terminal. We strongly suggest starting from a **freshly formatted Ubuntu installation**.

```sh
cd /tmp
echo "mkdir ~/git
cd ~/git
git clone https://github.com/Augusto-Viniciuss/linux-setup.git
cd ~/git/linux-setup
./install.sh
cd ~/git
git clone git@github.com:LASER-Robotics/laser_uav_system.git
cd ~/git/laser_uav_system
./install.sh" > run.sh && source run.sh
```
If you only wish to install the system, copy and paste the snippet below into your terminal.

```sh
cd /tmp
echo "mkdir ~/git
cd ~/git
git clone git@github.com:LASER-Robotics/laser_uav_system.git
cd ~/git/laser_uav_system
./install.sh" > run.sh && source run.sh
```

---

## Usage

Upon successful installation, detailed **execution examples** and configuration scripts for initiating the system can be found within the `tmux` directory of this repository.

The following command sequence demonstrates how to launch the **simulation of the lr7pro drone** integrated with the full LUS stack:

```sh
cd ~/laser_uav_system_ws/src/laser_uav_simulation/tmux/one_drone_test
./start.sh
```
**Supported Platform**

The lr7pro UAV, a supported platform for the LUS stack:


https://github.com/user-attachments/assets/6dfdd26c-1327-4a3c-a88e-73f5a55d394f

---

## Validation
The [LUS] system has undergone rigorous validation across various modalities and environments. The control stack, featuring NMPC (Nonlinear Model Predictive Control) + INDI (Incremental Nonlinear Dynamic Inversion), has been comprehensively tested.

This validation includes successful integration and testing of all major state estimation types:

VIO (Visual-Inertial Odometry)

GNSS (Global Navigation Satellite System)

LIO (Laser Inertial Odometry)

Validation was successfully achieved in both simulated environments and on the physical drone hardware (real-world flights).

Real-world validation using the x500 platform with the LIO and NMPC+INDI algorithms:


https://github.com/user-attachments/assets/92809e07-3467-4af6-8510-690d2e050b79


---

## Packages Included

This metapackage manages the following critical packages within the **[LUS]** ecosystem:

| Package | Description | Repository |
| :--- | :--- | :--- |
| `laser_uav_tui` | Contains **a Terminal User Interface (TUI) designed to provide a more user-friendly experience** and streamline experimental validation. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_tui)] |
| `laser_msgs` | Contains **custom message definitions** utilized across the entire software stack. | [[Link to repo](https://github.com/LASER-Robotics/laser_msgs)] |
| `laser_uav_controllers` | Implements **high and low-level controllers** for position and attitude tracking. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_controllers)] |
| `laser_uav_planner` | Implements **trajectory, motion, and path planners**. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_planner)] |
| `laser_uav_estimators` | Implements **filters and algorithms for UAV state estimation** crucial for control feedback. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_estimators)] |
| `laser_uav_lio-s` | Contains **Laser Inertial Odometry and Mapping (LIO) algorithms** integrated into the system. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_lio-s)] |
| `laser_uav_vio-s` | Contains **Visual-Inertial Odometry (VIO) algorithms** integrated into the system. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_vio-s)] |
| `laser_uav_managers` | **ROS 2 nodes for stack management**, utilizing controller and estimator classes to govern autonomous flight. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_managers)] |
| `laser_uav_lib` | Contains core **C++ and Python libraries** intended for general use in UAV systems development. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_lib)] |
| `laser_uav_px4_api` | **API for communication and interfacing with the onboard autopilot hardware** (flight controller). | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_px4_api)] |
| `laser_gazebo_resources` | Contains **models, plugins, world configurations, and other resources for Gazebo simulation**. | [[Link to repo](https://github.com/LASER-Robotics/laser_gazebo_resources)] |
| `laser_uav_simulation` | Contains the **simulation environment setup and the drone models** utilized by the project. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_simulation)] |
| `px4_firmware` | **PX4 autopilot firmware modified** for seamless operation with our custom API. | [[Link to repo](https://github.com/LASER-Robotics/px4_firmware-ROS2-)] |
| `px4_msgs` | Contains **message definitions utilized by the PX4 firmware**. | [[Link to repo](https://github.com/LASER-Robotics/px4_msgs)] |
| `micro_xrce_dds_agent` | Contains the **protocol agent facilitating the communication bridge** between the companion computer and the flight controller. | [[Link to repo](https://github.com/LASER-Robotics/micro_xrce_dds_agent)] |
| `laser_uav_drivers` | Contains the **ROS 2 wrappers for the SDKs of compatible sensors**. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_drivers)] |
| `laser_uav_deployment` | Contains **scripts and utilities to streamline the deployment process** on the physical UAV hardware. | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_deployment)] |

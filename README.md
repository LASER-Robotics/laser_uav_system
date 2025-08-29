# Laser Uav System [LUS]

[![Build Status](httpsa://github.com/LASER-Robotics/laser_uav_system/actions/workflows/main.yml/badge.svg)](https://github.com/LASER-Robotics/laser_uav_system/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Metapackage** repository for orchestrating and managing all packages of the [LUS] autonomous drone system.

This repository does not contain functional source code itself, but rather the package structure and dependencies that make up the entire system. It serves as the main entry point for cloning, installing, and running the project's entire ecosystem.

## System Overview

[LUS] is an open-source software platform designed to enable the autonomous operation of unmanned aerial vehicles (UAVs). The system is modular and divided into several ROS2 (Robot Operating System) packages, each responsible for a specific functionality, such as:

* **Perception:** Processing data from sensors.
* **Planning:** Generating trajectories and planning missions.
* **Control:** (High and Low)-level flight control algorithms.
* **Hardware API:** Comunication with flight controller autopilot.
* **Simulation:** Environments and models for Gazebo Classic simulation.

This metapackage ensures that all these components are installed and built in the correct version.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Ensure you have the following software installed:

* Ubuntu 22.04 (Jammy)
* Git

### Installation

We recommed that you install our linux setup para melhor usabilidade do nosso sistema se voce desejar instalar o linux setup junto ao sistema copie o cole o trecho abaixo no seu terminal, para isso recomendamos um ubuntu recem formatado

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
## Usage

After installation, you can find examples of how to run the system in the tmux folder of this repository. Below is a snippet that runs the simulation of an x500 drone with the LUS stack.

```sh
cd ~/git/laser_uav_system/tmux/onde_drone_test
./start.sh
```

## Packages Included

This metapackage manages the following packages:

| Package                                | Description                                                 | Repository                                      |
| -------------------------------------- | ----------------------------------------------------------- | ----------------------------------------------- |
| `laser_msgs`                        | Contains message definitions.     | [[Link to repo](https://github.com/LASER-Robotics/laser_msgs)]                                  |
| `laser_uav_controllers`                       | Implements high and low-level controllers for position tracking, attitude tracking, etc.     | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_controllers)]                                  |
| `laser_uav_managers`                    | ROS2 nodes for stack management. These nodes use the controller classes to manage autonomous flight.       | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_managers)]                                  |
| `laser_uav_planner`                      | Implements trajectory, motion, and path planners.            | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_planner)]                                  |
| `laser_uav_simulation`                    | Contains the simulation environment and the drone models we use.                | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_simulation)]                                  | 
| `laser_uav_px4_api`                    | API for communication with the onboard autopilot hardware.                | [[Link to repo](https://github.com/LASER-Robotics/laser_uav_px4_api)]                                  | 
| `px4_firmware`                    | Autopilot firmware modified for use in conjunction with our API.              | [[Link to repo](https://github.com/LASER-Robotics/px4_firmware-ROS2-)]                                  | 

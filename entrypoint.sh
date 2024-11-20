#!/bin/bash
set -e

# Setup the Demo environment
cd /home/crazyflie_mapping_demo/ros2_ws/
source /opt/ros/humble/setup.bash

exec "$@"
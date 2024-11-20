ARG ROS_DISTRO=humble
FROM osrf/ros:${ROS_DISTRO}-desktop

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Ignore setup.py warnings in building phase
ENV PYTHONWARNINGS="ignore:setup.py install is deprecated::setuptools.command.install"

# Install required apps
RUN apt-get update \
  && apt-get install -y \
  nano \
  git \
  python3-pip \
  && rm -rf /var/lib/apt/list/*

# Install gazebo dependencies
RUN apt-get update \
  && apt-get install -y \
  curl \
  lsb-release \
  gnupg \
  python3-colcon-common-extensions \
  && rm -rf /var/lib/apt/list/*

# Set up colcon_cd for future bash sessions
RUN echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
RUN echo "export _colcon_cd_root=/opt/ros/humble/" >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# Add Gazebo repository
RUN curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# Set up the gazebo version
ARG GZ_VERSION=fortress

# Install Gazebo
RUN apt-get update \
  && apt-get install -y \
  gz-${GZ_VERSION} \
  ros-${ROS_DISTRO}-ros-gz-sim \
  ros-${ROS_DISTRO}-ros-gz-bridge \
  && rm -rf /var/lib/apt/lists/*

# Set up the environment
ENV GZ_RESOURCE_PATH=/usr/share/gazebo-${GZ_VERSION}

# Create the necessary directories
RUN mkdir -p /root/crazyflie_mapping_demo/simulation_ws \
  && mkdir -p /root/crazyflie_mapping_demo/ros2_ws/src

# Set the working directory inside the container
WORKDIR /home/crazyflie_mapping_demo/simulation_ws

# Clone the repositorys into ros2 workspace
RUN git clone https://github.com/captain-bender/crazyflie-simulation.git

# Set the working directory inside the container
WORKDIR /home/crazyflie_mapping_demo/ros2_ws/src

# Clone the repository into simulation_ws
RUN git clone https://github.com/knmcguire/crazyflie_ros2_multiranger.git \
  && git clone https://github.com/knmcguire/ros_gz_crazyflie \
  && git clone https://github.com/IMRCLab/crazyswarm2 --recursive

# Install necessary tools and dependencies
RUN apt-get update \
  && apt-get install -y \
  libboost-program-options-dev \
  libusb-1.0-0-dev \
  python3-colcon-common-extensions \
  ros-${ROS_DISTRO}-motion-capture-tracking \
  ros-${ROS_DISTRO}-tf-transformations \
  ros-${ROS_DISTRO}-teleop-twist-keyboard \
  && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install cflib transform3D bresenham

# Change permissions
RUN sudo chmod 777 -R /home/crazyflie_mapping_demo/ros2_ws

# Set working directory to ros2_ws and build using colcon
WORKDIR /home/crazyflie_mapping_demo/ros2_ws

# Build
RUN . /opt/ros/humble/setup.sh \
  && colcon build --cmake-args -DBUILD_TESTING=ON

# Source ROS 2 workspace setup and set environment variable for GZ_SIM_RESOURCE_PATH
RUN echo "source /home/crazyflie_mapping_demo/ros2_ws/install/setup.bash" >> ~/.bashrc \
    && echo 'export GZ_SIM_RESOURCE_PATH="/home/crazyflie_mapping_demo/simulation_ws/crazyflie-simulation/simulator_files/gazebo/"' >> ~/.bashrc

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Interactive bash shell
CMD ["/bin/bash"]
# ROS 2 Crazyflie docker

This is an image that I generated using the workflow that is suggested by Kimberly McGuire in the [Crazyflie’s Adventures with ROS 2 and Gazebo](https://www.bitcraze.io/2024/09/crazyflies-adventures-with-ros-2-and-gazebo/).

I had to change some conflicts between libignition-gazebo and gz-sim plugins, but other than that it works as expected.

## Using CLI 
To build the image, you need to type:
```$
docker build --no-cache -t ros2-crazyflie .
```

To run the container, you need to type:
```$
docker run -it --rm --network=host --ipc=host -v /tmp/.X11-unix:/tmp/.X11-unix:rw --env=DISPLAY --name ros2-crazyflie-container ros2-crazyflie
```

## Using docker compose
To start the docker compose, you need to type:
```$
docker compose up -d
```
To get access in the container, you need to type:
```$
docker exec -it ros2-crazyflie-container /bin/bash
```
To stop the docker compose, you need to type:
```$
docker compose down
```

## Levevl of readiness
Not tested exhaustively. Use it on your own risk. If you discover issues, please report them.

## Environment (or it works in my machine)
It was testes in an Ubuntu 24.04.1 LTS machine

### Author (to blame)
Angelos Plastropoulos
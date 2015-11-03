# Docker (AUFS) Android Emulator
This will allow you to build a Docker image running android emulators with NoVNC so you can see and work with them.

This image is built on Ubuntu 14.04 and runs Docker with AUFS support. It allows you to run an Android Emulator via the Android SDK within the image and view the desktop via NoVNC.

**Note! - This only works if your docker host supports AUFS otherwise you'll run out of space.**

Follow these instructions to build a compatible docker host or cheat and use the public AMI I made available on AWS.

# To build a compatible docker host do the following:
*Setup Ubuntu 14.04 - if on AWS use the Ubuntu Marketplace AMI.
*Make sure your host VM has at least 40GB of space, this image uses ~25GB when running.
*With AUFS Docker can use the entire host file system for image space vs devicemapper which is the docker default but has terrible 10GB limits and increasing it will cause you problems.
*Run the follow commands to install the aufs version of docker.
```
sudo apt-get update
sudo apt-get -y install linux-image-extra-$(uname -r)
sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main\ > /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get -y install lxc-docker
```

*Clone this repo 
```
git clone git@github.com:typemismatch/android-emulator.git
cd android-emulator
```
*Build the docker image
```
docker build -t android-emulator .
```
*Run the image
```
docker run -dt -p 6901:6901 android-emulator
```
*You can now browse to your host IP on port 6901 and run auto_vnc.html. (pwd below)
*Once you're in, you'll use the browser to download the Android SDK and then setup your emulators.
*Note: The pre-built docker image below has the SDK and Emulators installed and tested.

*The default vnc password is "vncpassword".

# Pre-Built Docker Image

You can grab this image from the docker hub, docker pull https://hub.docker.com/r/craigw9292/android-emulator/


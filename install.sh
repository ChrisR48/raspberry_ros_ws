#!/bin/bash
WS_ROOT=$(cd `dirname $0`; pwd)
cd $WS_ROOT
# exit if one of the commands fail
set -e

if [ ! -r src ]; then
	mkdir src
fi

sudo apt-get install build-essential
# make sure rosdep and wstool are installed
sudo apt-get install python-rosdep python-wstool
sudo rosdep init || true
rosdep update
echo
# delete old files
echo Cleaning up old workspace files...
for f in .rosinstall* devel build; do
  [ -f $f ] && echo "rm -iv $f"  && rm -i $f
  [ -d $f ] && echo "rm -Irv $f" && rm -Ir $f
done
echo

ROS_DISTRO="indigo"

if [ ! -r /opt/ros/$ROS_DISTRO/setup.sh ]; then
	echo "Directory /opt/ros/$ROS_DISTRO does not exists!"
	exit 1
fi

source /opt/ros/$ROS_DISTRO/setup.sh
echo

# generate deprecated setup files in $WS_ROOT
cat >setup.sh <<EOF
# This setup location is DEPRECATED. Just forward to devel-space...
. $WS_ROOT/devel/setup.sh
EOF
cat >setup.bash <<EOF
# This setup location is DEPRECATED. Just forward to devel-space...
. $WS_ROOT/devel/setup.bash
EOF
cat >setup.zsh <<EOF
# This setup location is DEPRECATED. Just forward to devel-space...
. $WS_ROOT/devel/setup.zsh
EOF
# initialize workspace
cat >.rosinstall <<EOF
- setup-file: { local-name: $WS_ROOT/devel/setup.sh }
EOF
unset ROS_WORKSPACE
# merge rosinstall files from rosinstall/*.rosinstall rosinstall/$ROS_DISTRO/*.rosinstall
# for file in rosinstall/*.rosinstall; do
#    wstool merge $file -y
#done
#if [ -n "$ROS_DISTRO" -a -d rosinstall/$ROS_DISTRO ]; then
#    for file in rosinstall/$ROS_DISTRO/*.rosinstall; do
#        wstool merge $file -y
#    done
#fi
echo
# update workspace
wstool update
echo
# invoke catkin_make for the initial setupw
catkin_make cmake_check_build_system
echo
. $WS_ROOT/devel/setup.bash

# Initialization successful. Print message and exit.
cat <<EOF
============================================================================================
Workspace initialization completed.
You can setup your current shell's environment by entering
  source $PWD/devel/setup.bash
or by adding this command to your .bashrc file for automatic setup on each invocation of an interactive shell:
  echo "source $PWD/devel/setup.bash" >> ~/.bashrc
You can also modify your workspace config (e.g. for adding additional repositories or
packages) using the wstool command.
============================================================================================
EOF

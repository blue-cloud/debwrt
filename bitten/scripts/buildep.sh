#!/bin/bash
#
# Install DebWrt build dependencies
#
# Copyright (C) 2012 Johan van Zoomeren <amain@debwrt.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

sudo apt-get update
sudo apt-get install -y debootstrap \
			flex \
                        git \
                        subversion \
                        build-essential \
                        libncurses5-dev \
                        coreutils \
                        qemu-user-static \
                        gawk \
                        zlib1g-dev \
                        unzip\
			apt-cacher-ng \
			makedev
mkdir -p ~/dl


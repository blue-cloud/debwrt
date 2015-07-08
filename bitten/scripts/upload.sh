#!/bin/bash
#
# Copyright (C) 2013 Johan van Zoomeren <amain@debwrt.net>
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

if [ "${1}" == "" ]
then
cat <<EOF
usage: $(basename $0) <config/architecture/system/profile/build>

Publish completed builds to DebWrt site for donwload.

   config       Bitten Recipe Config short name (i.e. 12.09 or trunk)
   architecture mips, mipsel, ...
   system       ar71xx, ...
   profile      ubntrspro, ....
   build        167, 168, ...

example:

  upload.sh 12.09/mips/ar71xx/ubntrspro/167

EOF
   
   exit 1
fi

host=${DEBWRT_PUBLISH_URI:-"Please_configure_upload_URI"}
path=${DEBWRT_PUBLISH_PATH:-"Please_configure_upload_PATH"}
work=~/build/${1}
config=$(echo ${1} | awk -F "/" '{print $1}')

if [ "${config}" == "trunk" ]
then
   base="testing"
else
   base="releases"
fi

ssh ${host} "mkdir -p ${path}/${base}/${1}; ln -snf ${path}/${base}/${1} ${path}/${base}/${1}/../latest"
scp -r ${work}/bin/*/* ${host}:${path}/${base}/${1}


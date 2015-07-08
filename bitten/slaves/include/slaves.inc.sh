#!/bin/bash
#
# DebWrt - Debian on Embedded devices
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

function usage()
{
   cat <<EOF
usage: $(basename $0) <slave.ini> [ recipe.xml ] [ slave-arg1, .. ]

Start bitten slave with <slave.ini> configuration.

EOF

   exit 1
}

function patches()
{
   bcount=$(find /usr/local/lib/python2.7/dist-packages -name 'Bitten-*' | wc -l)

   if [ ${bcount} -eq 0 ]
   then
      echo "E: Can't find bitten-slave. Unable to apply patches."
      exit 1
   fi

   find /usr/local/lib/python2.7/dist-packages -name 'Bitten-*' \
     | while read dir
       do
         sudo patch -N -p 1 -d ${dir} <${BASEDIR}/patches/001_exit_no_pending.patch #>/dev/null
         sudo patch -N -p 1 -d ${dir} <${BASEDIR}/patches/002_basedir_makedirs #>/dev/null
       done 

   echo
}

run=${1}
ini=${2}
recipe=${3}

if [ ! "${run}" = "run" ]
then
  svn update ${BASEDIR}
  exec ${BASEDIR}/bin/$(basename $0) run $@
else
  shift
  shift
fi

if [ -f "${recipe}" ]
then
   # assume user supplied local recipy file
   shift
   mode=local
else
   unset recipe
   mode=remote
fi


[ ! -f "${ini}"    ] && usage

inipwd=~/.$(basename ${ini})
inipwd=${inipwd/.ini/}
[ ! -f "${inipwd}" ] && echo "E: can't read slave password (${inipwd})" && exit 1
. ${inipwd}
export DEBWRT_PUBLISH_URI
export DEBWRT_PUBLISH_PATH

eval $(awk -f ${BASEDIR}/include/ini.awk ${ini})

arch=${1/.*/}
name=$(hostname -f)
work=~/build
server_or_recipe="${recipe:-http://dev.debwrt.net}"
log=${work}/bitten.log
basedir='${config}/${platform}/${build}'

mkdir -p ${work}

cat <<EOF
Starting Bitten Slave

slave name         : ${name}
ini                : ${ini}
work               : ${work}
basedir            : ${basedir}
log                : ${log}
mode               : ${mode}
recipe             : ${server_or_recipe}

EOF

patches
set -x
bitten-slave --verbose \
             --keep-files \
             --config ${ini} \
             --work-dir ${work} \
             --build-dir ${basedir} \
             --log ${log} \
             --name ${name} \
             --dump-reports \
             --password ${password} \
             $@ \
             ${server_or_recipe}


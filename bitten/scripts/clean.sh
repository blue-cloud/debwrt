#!/bin/bash
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

if [ "${2}" == "" ]
then
cat <<EOF
usage: $(basename $0) <method> <config/architecture/system/profile>

Cleans builds in ${work:-<buildir>}.

   method	keep-previous: keep previous build
                keep-none: clean all previous builds
   config       Bitten Recipe Config short name
   architecture mips, mipsel, ...
   system       ar71xx, ...
   profile      ubntrspro, ....

example:

  clean.sh keep-last user/mips/ar71xx/ubntrspro

EOF
   
   exit 1
fi


method=${1}
work=~/build/${2}

function keep()
{
   local method=${1:-keep-previous}
   local keep_last=${2:-2}

   echo "I: cleaning builds in ${work} using method '${method}'"

   find ${work} -maxdepth 1 -regex ".*/[0-9]+"  \
     | sort -V \
     | head -n -${keep_last} \
     | while read dir
       do
          echo -n "   ${dir}..."
          sudo rm -rf ${dir}
          echo "done"
       done
}

case ${method} in
   keep-none) keep ${method} 1;;
   keep-previous) keep ${method} 2;;
   *) echo "E: method '${method} not found";;
esac


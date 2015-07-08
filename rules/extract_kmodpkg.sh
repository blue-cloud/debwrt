#!/bin/bash
#

if [ "$3" == "" ]; then
	echo "usage: `basename $0` source-kmod-package.ipk  extract-directory tmp-directory"
	echo
	exit 0
fi

kmodp=$1
droot=$2
tmpdir=$3

if [ ! -d "$droot" ]; then $droot is not a directory; exit 1; fi
if [ ! -d "$tmpdir" ]; then $tmpdir is not a directory; exit 1; fi

[ ! -e $kmodp ] && exit 1
[ ! -e $kmodp ] && echo "${kmodp} not found" && exit 1

tardir=$tmpdir/.extractkmodpkg.$$
mkdir -p $tardir

n=`basename $kmodp`
nn=${n/.ipk/}

# Extra from data.tar.gz only /lib
tar xzf $kmodp -C $tardir ./data.tar.gz
tar xzf $tardir/data.tar.gz -C $tardir ./lib

echo "I: Copy kernel modules(s) from $nn..."
findc=0
first=1
for kmod in `find $tardir -type f ! -name "data.tar.gz"`; do
   kmodf=`basename $kmod`

   # Only copy kernel module files if they do not already exist!
   if [ ".ko" = "${kmodf/*.ko/.ko}" ]; then
      findc=$(find $droot -type f -name $kmodf | wc -l) 
   else
      findc=0
   fi

   if [ "$findc" -eq 0 ]; then
	  tokmod=${kmod/$tardir/}
      todir=`dirname $droot/$tokmod`
	  mkdir -p $todir
      cp -a $kmod $droot/$tokmod
      echo "I:    - $kmodf (yes)"
   else
      echo "I:    - $kmodf (no)"
   fi
done

rm -rf $tardir

exit 0


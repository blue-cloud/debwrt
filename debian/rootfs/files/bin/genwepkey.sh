#!/bin/sh
#
# Amain <amain@debwrt.net>

echo -n "Enter WEP key 64bit=5 chars, 128bit=13 chars> "
read key
echo $key

( ! [ ${#key} -eq 5 ] && ! [ ${#key} -eq 13 ] ) && echo "key must be exactly 5 or 13 characters" && exit 1

[ ${#key} -eq 5 ] && bits="64"
[ ${#key} -eq 13 ] && bits="128" 

echo "WEP key length: ${#key} characters"
echo "WEP key bits  : $bits"
echo "WEP key hex   : "`echo -n $key | hexdump -e "${#key}/1 \"%02x\" \"\n\"" | cut -d ':' -f 1-${#key}`

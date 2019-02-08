#!/bin/bash

for f in /root/ldif/ch*Password.ldif; do
    newFile="/root/$(basename $f)"
    touch $newFile

    while read -r line; do
        case "$line" in
            *marker1*) echo "olcRootPW: $pw1" >> $newFile ;;
            *marker2*) echo "olcRootPW: $pw2" >> $newFile ;;
            *marker3*) echo "userPassword: $pw2" >> $newFile ;;
            *) echo "$line" >> $newFile ;;
        esac
    done < $f
done

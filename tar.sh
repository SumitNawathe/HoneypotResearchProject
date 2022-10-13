#/bin/bash

ls -l | grep '^d' | awk '{ print $9 }' | grep '^size' > files

FILES=$(cat files)

for i in "$FILES"; do
        mkdir packaged
        cp -r $i packaged
done

TIME=$(date +%s)

tar -czvf "$TIME".tar.gz packaged
rm -r packaged
rm files

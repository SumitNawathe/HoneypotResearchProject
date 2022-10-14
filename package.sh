#!/bin/bash

# Would need to nointeractively list and remove
count=`ls -l ~/*.tar.gz 2>/dev/null | wc -l`

# This could be used to eliminate older tar files in the host machine before pulling 
# if [[ $count != 0 ]]; then
# 	rm *.tar.gz
# fi

# Rely on files that ssh, zip the folders, and then finally import it into the workstation home directory
expect ssh.exp
expect package.exp


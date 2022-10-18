#!/bin/bash
# NOTE: MOVE TO HOME DIRECTORY FOR DEPLOYMENT

TIME=$( date +%s )
FILES=$( ls | grep "size_.*_data" | tr '\n' ' ' )
tar -czf "$TIME"_backup.tar.gz $FILES


#!/usr/local/bin/bash
find /mnt/storage -type file -name *.DS_Store -exec rm {} \;
find /mnt/data -type file -name *.DS_Store -exec rm {} \;

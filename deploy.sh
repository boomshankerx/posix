#!/bin/bash

to=~/posix

[[ -n $1 ]] && to=$1

echo $to

rsync -avz --delete --delete-excluded --exclude=.git --exclude=deploy.sh . $to 

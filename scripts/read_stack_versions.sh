#!/bin/bash

# get versions of the ocean stack running on the current barge containers

CONTAINERS="keeper-contracts brizo aquarius pleuston"
for CONTAINER in $CONTAINERS; do
    VERSION='unknown'
    DOCKER_ID=$(docker container ls | grep ocean_$CONTAINER | awk '{print $1}')
    if [ ! -z $DOCKER_ID ]; then
        docker cp "$DOCKER_ID:/$CONTAINER/.bumpversion.cfg" /tmp
        if [ -f /tmp/.bumpversion.cfg ]; then
            VERSION=`cat /tmp/.bumpversion.cfg | grep 'current_version =' | sed -e 's/^.*= //g'`
            rm /tmp/.bumpversion.cfg
        fi
    fi
    echo "$CONTAINER = $VERSION"
done


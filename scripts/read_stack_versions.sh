#!/bin/bash

# get versions of the ocean stack running on the current barge containers

KEEPER_VERSION='unknown'
BRIZO_VERSION='unknown'
AQUARIUS_VERSION='unknown'

DOCKER_ID=$(docker container ls | grep ocean_keeper-contracts | awk '{print $1}')
if [ ! -z $DOCKER_ID ]; then
    docker cp $DOCKER_ID:/keeper-contracts/.bumpversion.cfg /tmp
    KEEPER_VERSION=`cat /tmp/.bumpversion.cfg | grep 'current_version =' | sed -e 's/^.*= //g'`
    rm /tmp/.bumpversion.cfg
fi

DOCKER_ID=$(docker container ls | grep ocean_brizo | awk '{print $1}')
if [ ! -z $DOCKER_ID ]; then
    docker cp $DOCKER_ID:/brizo/.bumpversion.cfg /tmp
    BRIZO_VERSION=`cat /tmp/.bumpversion.cfg | grep 'current_version =' | sed -e 's/^.*= //g'`
    rm /tmp/.bumpversion.cfg
fi


DOCKER_ID=$(docker container ls | grep ocean_aquarius | awk '{print $1}')
if [ ! -z $DOCKER_ID ]; then
    docker cp $DOCKER_ID:/aquarius/.bumpversion.cfg /tmp
    AQUARIUS_VERSION=`cat /tmp/.bumpversion.cfg | grep 'current_version =' | sed -e 's/^.*= //g'`
    rm /tmp/.bumpversion.cfg
fi


echo "Ocean Stack Versions"
echo "keeper - v$KEEPER_VERSION"
echo "brizo - v$BRIZO_VERSION"
echo "aquarius - v$AQUARIUS_VERSION"

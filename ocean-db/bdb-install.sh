#!/bin/sh -x

curl -L https://github.com/bigchaindb/bigchaindb/archive/master.zip -o bigchaindb.zip
#unzip bigchaindb.zip -d . && mv bigchaindb-master/* . && rm -rf bigchaindb-master bigchaindb.zip
unzip bigchaindb.zip -d . && cd bigchaindb-master
docker-compose build bigchaindb
cd ..
rm -rf bigchaindb-master bigchaindb.zip


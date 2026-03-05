#/bin/bash
docker container stop ocean-node-1
docker container stop ocean-ipfs-1
docker container stop ocean-ocean-contracts-1
docker container stop ocean-elasticsearch-1
docker container stop ocean-typesense-1
docker container stop ocean-ganache-1
docker container stop ocean-faucet-1
docker container stop ocean-dashboard-1
docker container stop docker-registry
docker container stop ocean-storage-1

docker container rm ocean-node-1
docker container rm ocean-ipfs-1
docker container rm ocean-ocean-contracts-1
docker container rm ocean-elasticsearch-1
docker container rm ocean-typesense-1
docker container rm ocean-ganache-1
docker container rm ocean-faucet-1
docker container rm ocean-dashboard-1
docker container rm docker-registry
docker container rm ocean-storage-1

docker volume rm ocean-graphipfs
docker volume rm ocean-graphpgsql
docker volume rm ocean-provider1db
docker volume rm ocean-provider2db

docker network rm ocean_backend

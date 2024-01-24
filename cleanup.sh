#/bin/bash
docker container stop ocean_ipfs_1
docker container stop ocean_ocean-contracts_1
docker container stop ocean_typesense_1
docker container stop ocean_ganache_1
docker container stop ocean_dashboard_1
docker container stop ocean_computetodata_1
docker container stop ocean_kindcluster_1
docker container stop docker-registry
docker container rm ocean_ipfs_1
docker container rm ocean_ocean-contracts_1
docker container rm ocean_typesense_1
docker container rm ocean_ganache_1
docker container rm ocean_dashboard_1
docker container rm ocean_computetodata_1
docker container rm ocean_kindcluster_1
docker container rm docker-registry
docker volume rm ocean_typesense1
docker volume rm graphipfs

docker network rm kind
docker volume rm $(docker volume ls -q)

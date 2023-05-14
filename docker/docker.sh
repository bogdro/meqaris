#!/bin/bash

docker build --pull -t meqaris-db -f docker/Dockerfile-meqaris-db .

echo -n "PostgreSQL new master password: "
# e.g. postgres1234
read -s pg_master_pwd
echo ''

echo -n "PostgreSQL new 'meqaris' password: "
# e.g. meqaris01
read -s pg_meqaris_pwd
echo ''

# NOTE: we set some reasonable hostname, change the port if needed:
docker run -dp 9876:5432 --name meq-db --hostname meqaris-db -e POSTGRES_PASSWORD="$pg_master_pwd" -e PGPWD="$pg_meqaris_pwd" meqaris-db:latest

##docker stop meq-db
##docker rm meq-db

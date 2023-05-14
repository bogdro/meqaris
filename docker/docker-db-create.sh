#!/bin/bash
set -e

#psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
psql -v --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER meqaris WITH PASSWORD '$PGPWD';
	CREATE DATABASE meqaris WITH OWNER meqaris;
	GRANT ALL PRIVILEGES ON DATABASE meqaris TO meqaris;
EOSQL

# for databases older than 13.0, if someone chooses an older source image:
psql -v --username "$POSTGRES_USER" --dbname meqaris \
	-d meqaris -c 'CREATE EXTENSION IF NOT EXISTS btree_gist;'

#!/bin/bash
#
# Meqaris - Docker build script.
#
# Copyright (C) 2023-2025 Bogdan 'bogdro' Drozdowski, bogdro (at) users . sourceforge . net
#
# This file is part of Meqaris (Meeting Equipment and Room Invitation System),
#  software that allows booking meeting rooms and other resources using
#  e-mail invitations.
# Meqaris homepage: https://meqaris.sourceforge.io/
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

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

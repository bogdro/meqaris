#!/bin/bash
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

# Test for CalDAV-related command-line options

. test-func.bash

name='CalDAV1'
url='http://Cal_DAV_1'
$meqaris --add-caldav-server "$url" --name "$name"

res=`$psql -c \
	"select cals_name, cals_url, cals_username, cals_password, cals_realm from meqaris.meq_caldav_servers;"`
echo $res | grep "$name"
echo $res | grep "$url"

name='CalDAV1'
name2='CalDAV2'
url2='http://Cal_DAV_2'
user=c2user
pass=c2pass
realm=dav2_realm
$meqaris --update-caldav-server "$name" --name "$name2" --user "$user" --password "$pass" --realm "$realm"

res=`$psql -c \
	"select cals_name, cals_url, cals_username, cals_password, cals_realm from meqaris.meq_caldav_servers;"`
echo $res | grep "$name2"
echo $res | grep "$url"
echo $res | grep "$user"
echo $res | grep "$pass"
echo $res | grep "$realm"

res_name=cal_room
res_email=room@localhost
$meqaris --create "$res_name" --email "$res_email"

$meqaris --add-caldav-resource "$name2" --name "$res_name"

res=`$psql -c \
	"select r_email, cals_name, cals_url, cals_username, cals_password, cals_realm from meqaris.meq_caldav_servers join meqaris.meq_caldav_servers_resources on calres_cals_id = cals_id join meqaris.meq_resources on r_id = calres_r_id;"`
echo $res | grep "$name2"
echo $res | grep "$url"
echo $res | grep "$user"
echo $res | grep "$pass"
echo $res | grep "$realm"
echo $res | grep "$res_email"

$meqaris --delete-caldav-resource "$name2" --name "$res_name"

res=`$psql -c \
	"select r_email, cals_name, cals_url, cals_username, cals_password, cals_realm from meqaris.meq_caldav_servers join meqaris.meq_caldav_servers_resources on calres_cals_id = cals_id join meqaris.meq_resources on r_id = calres_r_id;"`
(echo $res | grep "$name2") && exit 1
(echo $res | grep "$res_email") && exit 2

$meqaris --delete-caldav-server "$name2"

res=`$psql -c \
	"select cals_name, cals_url, cals_username, cals_password, cals_realm from meqaris.meq_caldav_servers;"`
(echo $res | grep "$name2") && exit 3

exit 0

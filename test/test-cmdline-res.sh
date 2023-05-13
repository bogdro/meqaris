#!/bin/bash
#
# Copyright (C) 2023 Bogdan 'bogdro' Drozdowski, bogdro (at) users . sourceforge . net
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

# Test for resource-related command-line options

. test-func.bash

name='Room 406'
email=room406@localhost
$meqaris --create "$name" --email "$email"

res=`$psql -c \
	"select r_name, r_email, r_description from meqaris.meq_resources;"`
echo $res | grep "$name"
echo $res | grep "$email"

desc='room_406'
email=room405@localhost
$meqaris --update "$name" --email "$email" --description "$desc"

res=`$psql -c \
	"select r_name, r_email, r_description from meqaris.meq_resources;"`
echo $res | grep "$name"
echo $res | grep "$email"
echo $res | grep "$desc"

name2='Room 405'
$meqaris --update "$name" --name "$name2" --email "$email" --description "$desc"

res=`$psql -c \
	"select r_name, r_email, r_description from meqaris.meq_resources;"`
echo $res | grep "$name2"
echo $res | grep "$email"
echo $res | grep "$desc"

$meqaris --disable "$name2"

res=`$psql -c \
	"select r_name, r_email, r_description, r_enabled from meqaris.meq_resources where r_email = '$email';"`
echo $res | grep -w "f"

$meqaris --enable "$name2"

res=`$psql -c \
	"select r_name, r_email, r_description, r_enabled from meqaris.meq_resources where r_email = '$email';"`
echo $res | grep -w "t"

$meqaris --delete "$name2"

res=`$psql -c \
	"select r_name, r_email, r_description from meqaris.meq_resources;"`
(echo $res | grep "$name2") && exit 1

exit 0

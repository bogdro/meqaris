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

set -e
set -x

cwd=`pwd`
meqaris='../bin/meqaris --conf meqaris-test.ini'

organizer_mail='someone@localhost'
from="someone <someone@localhost>"
organizer="mailto:$organizer_mail"

year=`date +%Y`
month=$((`date +%m` + 1))
if ( test $month -lt 10 ); then
	month="0$month";
fi
if ( test $month -eq 13 ); then
	month="01";
	year=$((`date +%Y` + 1))
fi

inifile=meqaris-test.ini
l4p_config=meqaris-log4perl-test.cfg
logfile=meqaris-test.log

db_user=meqaris
db_name=meqaris-test
psql="psql -U $db_user -d $db_name -t"

init_l4p_force()
{
	cat > $l4p_config <<-L4J
		log4perl.rootLogger=TRACE, LOGFILE

		log4perl.appender.LOGFILE=Log::Log4perl::Appender::File
		log4perl.appender.LOGFILE.filename=$cwd/$logfile
		log4perl.appender.LOGFILE.mode=append

		log4perl.appender.LOGFILE.layout=PatternLayout
		log4perl.appender.LOGFILE.layout.ConversionPattern=[%d{yyyy-MM-dd HH:mm:ss}][PID=%P][UID=%x] %p - %m%n
	L4J
}

init_l4p()
{
	if ( test ! -e $l4p_config ); then
		init_l4p_force
	fi
}

init_cfg_force()
{
	cat > $inifile <<-INI
		[meqaris]
		dbtype=postgresql
		datadir=$cwd/..
		log4perl_config_location=$cwd/$l4p_config
		lock_dir=/run/lock

		[postgresql]
		username=$db_user
		password=meqaris01
		dbname=$db_name
		host=/run/postgresql
		port=5432
		connect_timeout=30
	INI
}

init_cfg()
{
	if ( test ! -e meqaris-test.ini ); then
		init_cfg_force
	fi
}

reinit()
{
	init_l4p
	init_cfg
}

reinit

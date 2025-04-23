#!/bin/bash
#
# Copyright (C) 2025 Bogdan 'bogdro' Drozdowski, bogdro (at) users . sourceforge . net
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

# Test for creating an event for multiple resources, some unknown to the system

. test-func.bash

test_log=test-multi-res-unkn.log

uid=`printf test_uid_%06d $1`
resource1=room403@localhost
resource2=doesnt_exist@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}01T184500"
dtend="$year${month}01T190000"

./create-mail --attendee "$resource1:mailto:$resource1","$resource2:mailto:$resource2" \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "room403 <$resource1>","doesnt_exist <$resource2>" --uid $uid \
| \
$meqaris > $test_log

grep "^Subject: Accepted: $subject" $test_log
grep "^Accepted: $subject" $test_log
grep "^From: .* <$resource1>" $test_log
grep "^To: $organizer_mail" $test_log
grep "^CC: $from" $test_log
grep 'method=REPLY' $test_log
check_status_code $test_log '2.0'

check_event_with_subject_and_uid "$subject" "$uid"

res=`$psql -c \
	"select rr_interval, r_email from meqaris.meq_resource_reservations join meqaris.meq_resources on r_id = rr_r_id where r_email = '$resource1';"`;
echo $res | grep "$year-$month-01 18:45:00"
echo $res | grep "$year-$month-01 19:00:00"
echo $res | grep "$resource1"

res=`$psql -c \
	"select rr_interval, r_email from meqaris.meq_resource_reservations join meqaris.meq_resources on r_id = rr_r_id where r_email = '$resource2';"`;
(echo $res | grep "$year-$month-01 17:30:00") && exit 1
(echo $res | grep "$year-$month-01 18:00:00") && exit 2
(echo $res | grep "$resource2") && exit 3

if [ -n "$delete_log" ]; then rm -f $test_log; fi

exit 0

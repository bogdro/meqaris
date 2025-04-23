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

# Test for updating an event - newer dtstamp and seq

. test-func.bash

test_log=test-event-upd4.log

uid=`printf test_uid_%06d $1`
resource=room403@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}01T104500"
dtend="$year${month}01T110000"

./create-mail --attendee "$resource:mailto:$resource" \
	--dtstamp 20000101T010203 --seq 1 \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "blah <$resource>" --uid $uid \
| \
$meqaris > $test_log

check_event_with_subject_and_uid "$subject" "$uid"

dtstart="$year${month}01T103000"
dtend="$year${month}01T104500"

# newer DTSTAMP and SEQUENCE:
./create-mail --attendee "$resource:mailto:$resource" \
	--dtstamp 20000101T020304 --seq 2 \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "blah <$resource>" --uid $uid \
| \
$meqaris > $test_log

grep "^Subject: Accepted: $subject" $test_log
grep "^Accepted: $subject" $test_log
grep "^From: .* <$resource>" $test_log
grep "^To: $organizer_mail" $test_log
grep "^CC: $from" $test_log
grep 'method=REPLY' $test_log

check_event_with_subject_and_uid "$subject" "$uid"

res=`$psql -c \
	"select rr_interval, r_email from meqaris.meq_resource_reservations join meqaris.meq_resources on r_id = rr_r_id where r_email = '$resource';"`;
echo $res | grep "$year-$month-01 10:30:00"
echo $res | grep "$year-$month-01 10:45:00"
echo $res | grep "$resource"

if [ -n "$delete_log" ]; then rm -f $test_log; fi

exit 0

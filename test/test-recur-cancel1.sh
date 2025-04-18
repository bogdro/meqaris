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

# Test for creating a recurring event and cancelling 1 recurrence

. test-func.bash

test_log=test-recur-cancel1.log

uid=test_uid_000026
resource=room403@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}02T040000"
dtend="$year${month}02T041500"

./create-mail --attendee "$resource:mailto:$resource" \
	--rrule 'FREQ=DAILY;COUNT=5;BYDAY=MO,TU,WE,TH,FR,SA,SU' \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "test <$resource>" --uid $uid \
| \
$meqaris > $test_log

# Make sure the event being cancelled exists:
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

./create-mail --attendee "$resource:mailto:$resource" \
	--method CANCEL --recur-id "$year${month}05T040000" \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "room <$resource>" --uid $uid \
| \
$meqaris > $test_log

# the output should be empty
grep "$subject" $test_log && exit 1

# We're cancelling just 1 recurrence, so the event should still exist:
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

# We're cancelling just 1 recurrence, so join with meqaris.meq_resource_reservations
# to check if there remaining reservations are in place.
res=`$psql -c \
	"select rr_interval, r_email from meqaris.meq_resource_reservations join meqaris.meq_resources on r_id = rr_r_id join meqaris.meq_events on e_id = rr_e_id where r_email = '$resource' and e_uid = '$uid';"`;
echo $res | grep "$year-$month-02 04:00:00"
echo $res | grep "$year-$month-02 04:15:00"
echo $res | grep "$year-$month-03 04:00:00"
echo $res | grep "$year-$month-03 04:15:00"
echo $res | grep "$year-$month-04 04:00:00"
echo $res | grep "$year-$month-04 04:15:00"
# the 5th is cancelled:
echo $res | grep "$year-$month-06 04:00:00"
echo $res | grep "$year-$month-06 04:15:00"
# no more occurrences:
(echo $res | grep "$year-$month-07 04:00:00") && exit 1
(echo $res | grep "$year-$month-07 04:15:00") && exit 2
echo $res | grep "$resource"

if [ -n "$delete_log" ]; then rm -f $test_log; fi

exit 0

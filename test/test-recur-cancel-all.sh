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

# Test for creating a recurring event and cancelling all recurrences

. test-func.bash

test_log=test-recur-cancel-all.log

uid=test_uid_000027
resource=room403@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}02T041500"
dtend="$year${month}02T043000"

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
	--method CANCEL \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "room <$resource>" --uid $uid \
| \
$meqaris > $test_log

# the output should be empty
grep "$subject" $test_log && exit 1

# We're cancelling attendee-based, so the event should still exist:
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

# We're cancelling for all attendees, so join with meqaris.meq_resource_reservations
# to check if there reservations are gone.
res=`$psql -c \
	"select r_email, e_summary, e_dtstamp, e_uid from meqaris.meq_events join meqaris.meq_resource_reservations on rr_e_id = e_id join meqaris.meq_resources on r_id = rr_r_id where e_summary = '$subject' and e_uid = '$uid';"`
(echo $res | grep "$subject") && exit 2
(echo $res | grep "$uid") && exit 3
(echo $res | grep "$resource") && exit 4

if [-n "$delete_log"]; then rm -f $test_log; fi

exit 0

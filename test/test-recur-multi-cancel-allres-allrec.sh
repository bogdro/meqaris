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

# Test for creating a recurring event for 2 resources and cancelling
# all recurrences for all of them

. test-func.bash

test_log=test-recur-multi-cancel-allres-allrec.log

uid=`printf test_uid_%06d $1`
resource1=room403@localhost
resource2=room404@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}02T053000"
dtend="$year${month}02T054500"

./create-mail --attendee "$resource1:mailto:$resource1","$resource2:mailto:$resource2" \
	--rrule 'FREQ=DAILY;COUNT=5;BYDAY=MO,TU,WE,TH,FR,SA,SU' \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "room403 <$resource1>","room404 <$resource2>" --uid $uid \
| \
$meqaris > $test_log

grep "^Subject: Accepted: $subject" $test_log
grep "^Accepted: $subject" $test_log
grep "^From: .* <$resource1>" $test_log
grep "^From: .* <$resource2>" $test_log
grep "^To: $organizer_mail" $test_log
grep "^CC: $from" $test_log
grep 'method=REPLY' $test_log
check_status_code $test_log '2.0'

# Make sure the event being cancelled exists:
check_event_with_subject_and_uid "$subject" "$uid"

./create-mail  \
	--method CANCEL \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "room403 <$resource1>","room404 <$resource2>" --uid $uid \
| \
$meqaris > $test_log

# the output should be empty
grep "$subject" $test_log && exit 1

# We're cancelling just recurrences, so the event should still exist:
check_event_with_subject_and_uid "$subject" "$uid"

# We're cancelling for all attendees, so join with meqaris.meq_resource_reservations
# to check if there reservations are gone.
res=$(get_event_by_summary_uid "$subject" $uid)
(echo $res | grep "$subject") && exit 2
(echo $res | grep "$uid") && exit 3
(echo $res | grep "$resource1") && exit 4
(echo $res | grep "$resource2") && exit 5

if [ -n "$delete_log" ]; then rm -f $test_log; fi

exit 0

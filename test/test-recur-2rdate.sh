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

# Test for creating a recurring event with 2 RDATEs

. test-func.bash

test_log=test-recur-2rdate.log

uid=`printf test_uid_%06d $1`
resource=room403@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}02T033000"
dtend="$year${month}02T034500"

./create-mail --attendee "$resource:mailto:$resource" \
	--rrule 'FREQ=DAILY;COUNT=5;BYDAY=MO,TU,WE,TH,FR,SA,SU' \
	--rdate "$year${month}12T033000,$year${month}13T033000" \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "test <$resource>" --uid $uid \
| \
$meqaris > $test_log

grep "^Subject: Accepted: $subject" $test_log
grep "^Accepted: $subject" $test_log
grep "^From: .* <$resource>" $test_log
grep "^To: $organizer_mail" $test_log
grep "^CC: $from" $test_log
grep 'method=REPLY' $test_log
check_status_code $test_log '2.0'

check_event_with_subject_and_uid "$subject" "$uid"

res=$(get_event_by_mail_uid $resource $uid)
echo $res | grep "$year-$month-02 03:30:00"
echo $res | grep "$year-$month-02 03:45:00"
echo $res | grep "$year-$month-03 03:30:00"
echo $res | grep "$year-$month-03 03:45:00"
echo $res | grep "$year-$month-04 03:30:00"
echo $res | grep "$year-$month-04 03:45:00"
echo $res | grep "$year-$month-05 03:30:00"
echo $res | grep "$year-$month-05 03:45:00"
echo $res | grep "$year-$month-06 03:30:00"
echo $res | grep "$year-$month-06 03:45:00"
# no more occurrences:
(echo $res | grep "$year-$month-07 03:30:00") && exit 1
(echo $res | grep "$year-$month-07 03:45:00") && exit 2
# the extra RDATEs:
echo $res | grep "$year-$month-12 03:30:00"
echo $res | grep "$year-$month-12 03:45:00"
echo $res | grep "$year-$month-13 03:30:00"
echo $res | grep "$year-$month-13 03:45:00"
echo $res | grep "$resource"

if [ -n "$delete_log" ]; then rm -f $test_log; fi

exit 0

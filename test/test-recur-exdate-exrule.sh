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

# Test for creating a recurring event with an EXDATE and an EXRULE

. test-func.bash

test_log=test-recur-exdate-exrule.log

uid=test_uid_000019
resource=room403@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}02T020000"
dtend="$year${month}02T021500"

./create-mail --attendee "$resource:mailto:$resource" \
	--rrule 'FREQ=DAILY;COUNT=5;BYDAY=MO,TU,WE,TH,FR,SA,SU' \
	--exdate "$year${month}05T020000" \
	--exrule 'FREQ=YEARLY;BYMONTHDAY=3' \
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

res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

res=`$psql -c \
	"select rr_interval, r_email from meqaris.meq_resource_reservations join meqaris.meq_resources on r_id = rr_r_id join meqaris.meq_events on e_id = rr_e_id where r_email = '$resource' and e_uid = '$uid';"`;
echo $res | grep "$year-$month-02 02:00:00"
echo $res | grep "$year-$month-02 02:15:00"
# the 3rd is excluded:
echo $res | grep "$year-$month-04 02:00:00"
echo $res | grep "$year-$month-04 02:15:00"
# the 5th is excluded:
echo $res | grep "$year-$month-06 02:00:00"
echo $res | grep "$year-$month-06 02:15:00"
# no more occurrences:
(echo $res | grep "$year-$month-07 02:00:00") && exit 1
(echo $res | grep "$year-$month-07 02:15:00") && exit 2
echo $res | grep "$resource"

rm -f $test_log

exit 0

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

# Test for creating a recurring event for 2 resources and cancelling
# all recurrences for one of them

. test-func.bash

test_log=test-recur-multi-cancel-1res-all.log

uid=test_uid_000030
resource1=room403@localhost
resource2=room404@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}02T050000"
dtend="$year${month}02T051500"

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

# Make sure the event being cancelled exists:
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

./create-mail --attendee "$resource2:mailto:$resource2" \
	--method CANCEL \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "room404 <$resource2>" --uid $uid \
| \
$meqaris > $test_log

# the output should be empty
grep "$subject" $test_log && exit 1

# We're cancelling just 1 recurrence, so the event should still exist:
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

# We're cancelling for just 1 attendee, so join with meqaris.meq_resource_reservations
# to check if there remaining reservations are in place.
# resource1:
res=`$psql -c \
	"select rr_interval, r_email from meqaris.meq_resource_reservations join meqaris.meq_resources on r_id = rr_r_id join meqaris.meq_events on e_id = rr_e_id where r_email = '$resource1' and e_uid = '$uid';"`;
echo $res | grep "$year-$month-02 05:00:00"
echo $res | grep "$year-$month-02 05:15:00"
echo $res | grep "$year-$month-03 05:00:00"
echo $res | grep "$year-$month-03 05:15:00"
echo $res | grep "$year-$month-04 05:00:00"
echo $res | grep "$year-$month-04 05:15:00"
echo $res | grep "$year-$month-05 05:00:00"
echo $res | grep "$year-$month-05 05:15:00"
echo $res | grep "$year-$month-06 05:00:00"
echo $res | grep "$year-$month-06 05:15:00"
# no more occurrences:
(echo $res | grep "$year-$month-07 05:00:00") && exit 1
(echo $res | grep "$year-$month-07 05:15:00") && exit 2
echo $res | grep "$resource1"

# We're cancelling for just 1 attendee, so join with meqaris.meq_resource_reservations
# to check if there aren't any actual reservations.
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events join meqaris.meq_resource_reservations on rr_e_id = e_id join meqaris.meq_resources on r_id = rr_r_id where r_email = '$resource2';"`
# where e_summary = '$subject' and e_uid = '$uid'
(echo $res | grep "$uid") && exit 1

rm -f $test_log

exit 0

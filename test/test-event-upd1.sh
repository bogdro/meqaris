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

# Test for updating an event - same dtstamp

. test-func.bash

test_log=test-event-upd1.log

uid=test_uid_000036
resource=room403@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}01T113000"
dtend="$year${month}01T114500"

./create-mail --attendee "$resource:mailto:$resource" \
	--dtstamp 20000101T010203 --seq 1 \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "blah <$resource>" --uid $uid \
| \
$meqaris > $test_log

# Make sure the event exists:
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

dtstart="$year${month}01T111500"
dtend="$year${month}01T113000"

# same hardcoded DTSTAMP and SEQUENCE:
./create-mail --attendee "$resource:mailto:$resource" \
	--dtstamp 20000101T010203 --seq 1 \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "blah <$resource>" --uid $uid \
| \
$meqaris > $test_log

# the output should be empty
grep "$subject" $test_log && exit 1

res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

# Shouldn't be updated - should have the old event times
res=`$psql -c \
	"select rr_interval, r_email from meqaris.meq_resource_reservations join meqaris.meq_resources on r_id = rr_r_id where r_email = '$resource';"`;
echo $res | grep "$year-$month-01 11:30:00"
echo $res | grep "$year-$month-01 11:45:00"
echo $res | grep "$resource"

rm -f $test_log

exit 0

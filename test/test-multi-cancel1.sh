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

# Test for cancelling an event with multiple resources for just one of them

. test-func.bash

test_log=test-multi-cancel1.log

# the UID of the event being created and cancelled:
uid=test_uid_000040
resource1=room403@localhost
resource2=room404@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}01T101500"
dtend="$year${month}01T103000"

./create-mail --attendee "$resource1:mailto:$resource1","$resource2:mailto:$resource2" \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "room403 <$resource1>","room404 <$resource2>" --uid $uid \
| \
$meqaris > $test_log

# Make sure the event being cancelled exists:
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

./create-mail --attendee "$resource2:mailto:$resource2" \
	--method CANCEL \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "404 <$resource2>" --uid $uid \
| \
$meqaris > $test_log

# the output should be empty
grep "$subject" $test_log && exit 1

# We're cancelling for just 1 attendee, so the event should still exist:
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"

# We're cancelling for just 1 attendee, so join with meqaris.meq_resource_reservations
# to check if there remaining reservations are in place.
res=`$psql -c \
	"select r_email, e_summary, e_dtstamp, e_uid from meqaris.meq_events join meqaris.meq_resource_reservations on rr_e_id = e_id join meqaris.meq_resources on r_id = rr_r_id where e_summary = '$subject' and e_uid = '$uid';"`
echo $res | grep "$subject"
echo $res | grep "$uid"
echo $res | grep "$resource1"

if [-n "$delete_log"]; then rm -f $test_log; fi

exit 0

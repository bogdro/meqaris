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

# Test for a conflicting event

. test-func.bash

test_log=test-event-conflict.log

uid=test_uid_000034
resource=room403@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}01T114500"
dtend="$year${month}01T120000"

./create-mail --attendee "$resource:mailto:$resource" \
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

uid=test_uid_000035
resource=room403@localhost
subject="Event $uid $RANDOM"
dtstart="$year${month}01T114000"
dtend="$year${month}01T115000"

./create-mail --attendee "$resource:mailto:$resource" \
	--dtstart $dtstart --dtend $dtend --from "$from" \
	--organizer "$organizer" --subject "$subject" \
	--to "sth <$resource>" --uid $uid \
| \
$meqaris > $test_log

grep "^Subject: Declined: $subject" $test_log
grep "^Declined: $subject" $test_log
grep "^From: .* <$resource>" $test_log
grep "^To: $organizer_mail" $test_log
grep "^CC: $from" $test_log
grep 'method=REPLY' $test_log
grep 'The resource is booked in the selected period.' $test_log

# In negative tests, check all entries in case just one condition matches
res=`$psql -c \
	"select e_summary, e_dtstamp, e_uid from meqaris.meq_events;"`
# where e_summary = '$subject' and e_uid = '$uid'
(echo $res | grep "$subject") && exit 1
(echo $res | grep "$uid") && exit 2

rm -f $test_log

exit 0

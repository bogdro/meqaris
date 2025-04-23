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

# Test suite - runs all tests

set -e
set -x

. test-func.bash

uid=1

./test-init.sh
./test-cmdline-res.sh
./test-cmdline-caldav.sh

./test-first-event.sh $uid; uid=$((uid + 1))
./test-event-upd1.sh $uid; uid=$((uid + 1))
./test-event-upd2.sh $uid; uid=$((uid + 1))
./test-event-upd3.sh $uid; uid=$((uid + 1))
./test-event-upd4.sh $uid; uid=$((uid + 1))
./test-event-conflict.sh $uid; uid=$((uid + 1))
./test-duration.sh $uid; uid=$((uid + 1))
./test-past.sh $uid; uid=$((uid + 1))
./test-role-chair.sh $uid; uid=$((uid + 1))
./test-role-non.sh $uid; uid=$((uid + 1))
./test-role-opt.sh $uid; uid=$((uid + 1))
./test-no-attendees.sh $uid; uid=$((uid + 1))
./test-no-time.sh $uid; uid=$((uid + 1))
./test-diff-send-org.sh $uid; uid=$((uid + 1))
./test-cancel.sh $uid; uid=$((uid + 1))
./test-multi-res.sh $uid; uid=$((uid + 1))
./test-multi-cancel1.sh $uid; uid=$((uid + 1))
./test-multi-cancel-all.sh $uid; uid=$((uid + 1))
./test-multi-cancel-all-status.sh $uid; uid=$((uid + 1))
./test-recur.sh $uid; uid=$((uid + 1))
./test-recur-rdate.sh $uid; uid=$((uid + 1))
./test-recur-2rdate.sh $uid; uid=$((uid + 1))
./test-recur-exdate.sh $uid; uid=$((uid + 1))
./test-recur-2exdate.sh $uid; uid=$((uid + 1))
./test-recur-exrule.sh $uid; uid=$((uid + 1))
./test-recur-exdate-exrule.sh $uid; uid=$((uid + 1))
./test-recur-inf.sh $uid; uid=$((uid + 1))
./test-recur-upd.sh $uid; uid=$((uid + 1))
./test-recur-rdate-period.sh $uid; uid=$((uid + 1))
./test-recur-2res.sh $uid; uid=$((uid + 1))
./test-recur-cancel1.sh $uid; uid=$((uid + 1))
./test-recur-cancel-all.sh $uid; uid=$((uid + 1))
./test-recur-cancel-all-status.sh $uid; uid=$((uid + 1))
./test-recur-multi-cancel-1res-1rec.sh $uid; uid=$((uid + 1))
./test-recur-multi-cancel-1res-all.sh $uid; uid=$((uid + 1))
./test-recur-multi-cancel-allres-1rec.sh $uid; uid=$((uid + 1))
./test-recur-multi-cancel-allres-allrec.sh $uid; uid=$((uid + 1))
./test-recur-multi-cancel-allres-allrec-status.sh $uid; uid=$((uid + 1))
./test-unsupp-method.sh $uid; uid=$((uid + 1))
./test-adjacent-events.sh $uid; uid=$((uid + 1))
./test-disabled.sh $uid; uid=$((uid + 1))
./test-no-organiser.sh $uid; uid=$((uid + 1))
./test-cancel-no-exist.sh $uid; uid=$((uid + 1))
./test-multi-same-res.sh $uid; uid=$((uid + 1))
./test-multi-res-unkn.sh $uid; uid=$((uid + 1))
./test-no-uid.sh $uid; uid=$((uid + 1))

$meqaris --destroy-db
rm -f $l4p_config $logfile $inifile

exit 0

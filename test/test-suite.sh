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

./test-init.sh
./test-cmdline-res.sh
./test-cmdline-caldav.sh
./test-first-event.sh
./test-event-upd1.sh
./test-event-upd2.sh
./test-event-upd3.sh
./test-event-upd4.sh
./test-event-conflict.sh
./test-duration.sh
./test-past.sh
./test-role-chair.sh
./test-role-non.sh
./test-role-opt.sh
./test-no-attendees.sh
./test-no-time.sh
./test-diff-send-org.sh
./test-cancel.sh
./test-multi-res.sh
./test-multi-cancel1.sh
./test-multi-cancel-all.sh
./test-multi-cancel-all-status.sh
./test-recur.sh
./test-recur-rdate.sh
./test-recur-2rdate.sh
./test-recur-exdate.sh
./test-recur-2exdate.sh
./test-recur-exrule.sh
./test-recur-exdate-exrule.sh
./test-recur-inf.sh
./test-recur-upd.sh
./test-recur-rdate-period.sh
./test-recur-2res.sh
./test-recur-cancel1.sh
./test-recur-cancel-all.sh
./test-recur-cancel-all-status.sh
./test-recur-multi-cancel-1res-1rec.sh
./test-recur-multi-cancel-1res-all.sh
./test-recur-multi-cancel-allres-1rec.sh
./test-recur-multi-cancel-allres-allrec.sh
./test-recur-multi-cancel-allres-allrec-status.sh
./test-unsupp-method.sh
./test-adjacent-events.sh
./test-disabled.sh
./test-no-organiser.sh
./test-cancel-no-exist.sh
./test-multi-same-res.sh
./test-multi-res-unkn.sh
./test-no-uid.sh

$meqaris --destroy-db
rm -f $l4p_config $logfile $inifile

exit 0

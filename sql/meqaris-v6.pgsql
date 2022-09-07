/*
 * Meqaris - the v6 database script.
 *
 * Copyright (C) 2022 Bogdan 'bogdro' Drozdowski, bogdro (at) users . sourceforge . net
 *
 * This file is part of Meqaris (Meeting Equipment and Room Invitation System),
 *  software that allows booking meeting rooms and other resources using
 *  e-mail invitations.
 * Meqaris homepage: https://meqaris.sourceforge.io/
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
Required for indices, triggers and their comments.
*/
set schema 'meqaris';

alter table meqaris.meq_resource_reservations drop constraint rr_uid_unique;
alter table meqaris.meq_resource_reservations alter column rr_uid set not null;

create index rr_uid_index on meq_resource_reservations (rr_uid);
comment on index rr_uid_index is 'The index for searching reservations by UID';

update meqaris.meq_config set c_value = '6'
where c_name = 'db_version';

/*
 * Meqaris - the v7 database script.
 *
 * Copyright (C) 2023 Bogdan 'bogdro' Drozdowski, bogdro (at) users . sourceforge . net
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

alter table meqaris.meq_resources add constraint r_email_syntax
check (r_email ~* '^[a-z0-9_][a-z0-9_.\-]*@[a-z0-9_.\-]+$');

create table meqaris.meq_events
(
	e_id serial constraint ev_pk primary key,
	e_entry_date timestamp with time zone not null default now(),
	e_organiser varchar(1000) not null,
	e_summary varchar(1000),
	e_dtstamp timestamp with time zone,
	e_uid varchar(1000) not null, /* not unique for finer-grained manipulation of events with multiple resources */
	e_seq int not null default 0 constraint e_seq_nonneg check (e_seq >= 0),
	e_data text
);

comment on table meqaris.meq_events is 'The table for meeting events';
comment on column meqaris.meq_events.e_id is 'Event ID (assigned automatically)';
comment on column meqaris.meq_events.e_entry_date is 'Event database entry timestamp'; /* for partitioning, if wanted */
comment on column meqaris.meq_events.e_organiser is 'Event organiser';
comment on column meqaris.meq_events.e_summary is 'Event summary (title)';
comment on column meqaris.meq_events.e_dtstamp is 'Event date/time stamp (sequential ID)';
comment on column meqaris.meq_events.e_uid is 'Event unique ID';
comment on column meqaris.meq_events.e_seq is 'Event sequential ID (for later updates)';
comment on column meqaris.meq_events.e_data is 'Event data (iCalendar)';

create index e_uid_index on meq_events (e_uid);
comment on index e_uid_index is 'The index for searching events by UID';

insert into meqaris.meq_events (e_organiser, e_summary, e_dtstamp, e_uid, e_seq, e_data)
select distinct rr_organiser, rr_summary, rr_dtstamp, rr_uid, rr_seq, rr_data
from meqaris.meq_resource_reservations;

alter table meqaris.meq_resource_reservations
add column rr_e_id int;

update meqaris.meq_resource_reservations set rr_e_id = (
select e_id from meqaris.meq_events where e_uid = rr_uid);

alter table meqaris.meq_resource_reservations
alter column rr_e_id set not null;

alter table meqaris.meq_resource_reservations
add constraint rr_e_fk foreign key (rr_e_id) references meqaris.meq_events (e_id) on delete cascade;

create index meq_resource_reservations_events_fk on meq_resource_reservations (rr_e_id);
comment on index meq_resource_reservations_events_fk is 'The index for the reservation''s event foreign key';

alter table meqaris.meq_resource_reservations
drop column rr_organiser;

alter table meqaris.meq_resource_reservations
drop column rr_summary;

alter table meqaris.meq_resource_reservations
drop column rr_dtstamp;

alter table meqaris.meq_resource_reservations
drop column rr_uid;

alter table meqaris.meq_resource_reservations
drop column rr_seq;

alter table meqaris.meq_resource_reservations
drop column rr_data;

alter index meq_resource_reservations_fk
rename to meq_resource_reservations_resource_fk;

create table meqaris.meq_caldav_servers
(
	cals_id serial constraint cals_pk primary key,
	cals_name varchar(1000) not null,
	cals_url varchar(1000) not null constraint cals_url_unique unique,
	cals_username varchar(1000),
	cals_password varchar(1000),
	cals_realm varchar(1000)
);

comment on table meqaris.meq_caldav_servers is 'The table for CalDAV servers';
comment on column meqaris.meq_caldav_servers.cals_id is 'CalDAV server ID (assigned automatically)';
comment on column meqaris.meq_caldav_servers.cals_name is 'CalDAV server name';
comment on column meqaris.meq_caldav_servers.cals_url is 'CalDAV server URL';
comment on column meqaris.meq_caldav_servers.cals_username is 'CalDAV server username (if needed)';
comment on column meqaris.meq_caldav_servers.cals_password is 'CalDAV server password (if needed)';
comment on column meqaris.meq_caldav_servers.cals_realm is 'CalDAV server access realm (if needed)';

create table meqaris.meq_caldav_servers_resources
(
	calres_cals_id int constraint calres_cals_fk not null
		references meqaris.meq_caldav_servers (cals_id) on delete cascade,
	calres_r_id int constraint calres_r_fk not null
		references meqaris.meq_resources (r_id) on delete cascade,
	constraint calres_unique unique (calres_cals_id, calres_r_id)
);

comment on table meqaris.meq_caldav_servers_resources is 'The table for CalDAV server-to-resource mapping';
comment on column meqaris.meq_caldav_servers_resources.calres_cals_id is 'CalDAV server ID';
comment on column meqaris.meq_caldav_servers_resources.calres_r_id is 'Resource ID';

create index meq_caldav_servers_resources_cal_fk on meq_caldav_servers_resources (calres_cals_id);
comment on index meq_caldav_servers_resources_cal_fk is 'The index for the calendar server foreign key in CalDAV server-to-resource mapping';

create index meq_caldav_servers_resources_resource_fk on meq_caldav_servers_resources (calres_r_id);
comment on index meq_caldav_servers_resources_resource_fk is 'The index for the resource foreign key in CalDAV server-to-resource mapping';

update meqaris.meq_config set c_value = '7'
where c_name = 'db_version';

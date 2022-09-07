/*
 * Meqaris - the full database script.
 *
 * Copyright (C) 2022 Bogdan 'bogdro' Drozdowski, bogdro (at) users . sourceforge . net
 *
 * This file is part of Meqaris (Meeting Equipment and Room Invitation System),
 *  software that allows booking meeting rooms and other resources using
 *  e-mail invitations.
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
createdb meqaris
*/

create schema meqaris;
comment on schema meqaris is 'The main schema for the Meqaris application';

/* Depends on the database version, enabled by default on newer:
create language plpgsql;
*/

/*
Required for indices, triggers and their comments.
*/
set schema 'meqaris';

/*
Required for GiST indices with integer columns.
*/
create extension if not exists btree_gist;

------------------ MEETING RESOURCES ---------------------

create table meqaris.meq_resources
(
	r_id serial constraint res_pk primary key,
	r_name varchar(1000) not null,
	r_email varchar(1000) not null constraint r_email_unique unique,
	r_description varchar(1000),
	r_enabled bool not null default true
);

comment on table meqaris.meq_resources is 'The table for meeting resources (rooms, equipment)';
comment on column meqaris.meq_resources.r_id is 'Meeting resource''s ID (assigned automatically)';
comment on column meqaris.meq_resources.r_name is 'Meeting resource''s name';
comment on column meqaris.meq_resources.r_email is 'Meeting resource''s e-mail address';
comment on column meqaris.meq_resources.r_description is 'Meeting resource''s description';
comment on column meqaris.meq_resources.r_enabled is 'Whether or not this meeting resource is enabled';

------------------ MEETING RESOURCE RESERVATIONS / BOOKINGS ------------------

create table meqaris.meq_resource_reservations
(
	rr_id serial constraint rr_pk primary key,
	rr_r_id int constraint rr_fk not null references meqaris.meq_resources (r_id),
	rr_interval tstzrange not null,
	rr_organiser varchar(1000) not null,
	rr_summary varchar(1000),
	rr_dtstamp timestamp with time zone,
	rr_uid varchar(1000) constraint rr_uid_unique unique,
	rr_seq int not null default 0 constraint rr_seq_nonneg check (rr_seq >= 0),
	rr_data text,
	constraint rr_interval_in_future check (lower(rr_interval) > now() and upper(rr_interval) > now()),
	-- this is the constraint/index that does all the work:
	constraint rr_interval_excl exclude using gist (rr_r_id with =, rr_interval with &&)
);

comment on table meqaris.meq_resource_reservations is 'The table for meeting resource reservations/bookings';
comment on column meqaris.meq_resource_reservations.rr_id is 'Reservation ID (assigned automatically)';
comment on column meqaris.meq_resource_reservations.rr_r_id is 'Reservation resource''s ID';
comment on column meqaris.meq_resource_reservations.rr_interval is 'Reservation time interval';
comment on column meqaris.meq_resource_reservations.rr_organiser is 'Reservation organiser';
comment on column meqaris.meq_resource_reservations.rr_summary is 'Reservation summary (title)';
comment on column meqaris.meq_resource_reservations.rr_dtstamp is 'Reservation date/time stamp (sequential ID)';
comment on column meqaris.meq_resource_reservations.rr_uid is 'Reservation unique ID';
comment on column meqaris.meq_resource_reservations.rr_seq is 'Reservation sequential ID (for later updates)';
comment on column meqaris.meq_resource_reservations.rr_data is 'Reservation data (iCalendar)';

create index meq_resource_reservations_fk on meq_resource_reservations (rr_r_id);
comment on index meq_resource_reservations_fk is 'The index for the reservation''s resource foreign key';

------------------ CONFIGURATION ------------------

create table meqaris.meq_config
(
	c_name varchar(1000) constraint conf_pk primary key,
	c_value varchar(1000),
	c_description varchar(1000)
);

comment on table meqaris.meq_config is 'The table for Meqaris configuration';
comment on column meqaris.meq_config.c_name is 'Configuration parameter name';
comment on column meqaris.meq_config.c_value is 'Configuration parameter value';
comment on column meqaris.meq_config.c_description is 'Configuration parameter description';

insert into meqaris.meq_config (c_name, c_value, c_description)
values ('mail_server', null, 'The address of the mail server to use (NULL = default)');

insert into meqaris.meq_config (c_name, c_value, c_description)
values ('mail_server_port', null, 'The port on the mail server to use (NULL = default)');

insert into meqaris.meq_config (c_name, c_value, c_description)
values ('mail_sending_method', null, 'The method to send mail replies NULL=default, Mail::Internet, mail_command');

insert into meqaris.meq_config (c_name, c_value, c_description)
values ('mail_command', null, 'The command to pipe mail replies to when mail_sending_method="mail_command" (NULL = none)');

insert into meqaris.meq_config (c_name, c_value, c_description)
values ('reply_detail_level', '0', 'An integer saying how much detailed will the replies be. 0 = the default.');

insert into meqaris.meq_config (c_name, c_value, c_description)
values ('db_version', '4', 'The current version of the Meqaris database');

/*
 * Meqaris - the v2 database script.
 *
 * Copyright (C) 2022-2023 Bogdan 'bogdro' Drozdowski, bogdro (at) users . sourceforge . net
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

insert into meqaris.meq_config (c_name, c_value, c_description)
values ('mail_server', null, 'The address of the mail server to use (NULL = default)');

insert into meqaris.meq_config (c_name, c_value, c_description)
values ('mail_server_port', null, 'The port on the mail server to use (NULL = default)');

update meqaris.meq_config set c_value = '2'
where c_name = 'db_version';

# Meqaris #

## Description ##

Meqaris (Meeting Equipment and Room Invitation System) is a system that allows booking resources using e-mail invitations.

Meqaris allows to:

- register meeting resources,
- send invitations to the resources (requires mail server support),
- receive positive and negative replies.

Features:

- supports RFC 2445 iCalendar attachments in mails, both with the text/calendar and application/ics MIME types,
- sends mail replies back to the sender,
- supports creation, updates and cancellation of single events,
- supports creation, updates and cancellation of recurring events,
- supports both interval-defined and duration-defined events,
- automatically updates its own database structures to the required version when needed,
- supports time zones,
- mail replies and logs can have various verbosity levels,
- has wide logging capabilities,
- has a command-line interface - no need to run SQL statements.

Meqaris homepage: <https://meqaris.sourceforge.io/>

----------------------------------------------------------------

## Requirements ##

1. Perl (<https://www.perl.org/>), along with some modules (see the documentation inside the package),
2. a PostgreSQL database server (<https://www.postgresql.org/>), version 9.2 or newer, with the `btree_gist` extension binary file.

----------------------------------------------------------------

## Compatibility ##

Various versions of Meqaris were successfully used with the following components in the following versions:

1. PostgreSQL:
	- 14.x (checked: 14.1)
2. Perl:
	- v5.34.0
3. Postfix (<https://www.postfix.org/>):
	- 3.6.5

Other versions may also work.

----------------------------------------------------------------

## ChangeLog ##

For a summary of changes, refer to the `ChangeLog` file in the package.

----------------------------------------------------------------

# WARNING #

This repository is for testing purposes.
The code here may not work properly or even compile.
As for now, use the official packages from SourceForge.


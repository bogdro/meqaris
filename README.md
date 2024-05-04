# Meqaris #

## Description ##

Meqaris (Meeting Equipment and Room Invitation System) is a system that allows booking resources using e-mail invitations.

Meqaris allows to:

-   register meeting resources,
-   send invitations to the resources (requires mail server support),
-   receive positive and negative replies.

Features:

-   supports RFC 2445/5545 iCalendar attachments in mails (RFC 2446/5546 and 2447/6047), both with the text/calendar and application/ics MIME types,
-   sends mail replies back to the sender (RFC 2446/5546 and 2447/6047),
-   can pipe the response mail to a specified command,
-   supports creation, updates and cancellation of single events,
-   supports creation, updates and cancellation of recurring events,
-   supports both interval-defined and duration-defined events,
-   supports CalDAV (RFC 4791),
-   supports booking multiple resources in a single invitation,
-   automatically updates its own database structures to the required version when needed,
-   supports time zones,
-   mail replies and logs can have various verbosity levels,
-   has wide logging capabilities,
-   has a command-line interface - no need to run SQL statements,
-   portable and system-independent.

Meqaris homepage: <https://meqaris.sourceforge.io/>

## Requirements ##

1.  Perl (<https://www.perl.org/>), along with some modules (see the documentation inside the package),
2.  a PostgreSQL database server (<https://www.postgresql.org/>), version 9.2 or newer, with the `btree_gist` extension.

## Compatibility ##

Various versions of Meqaris were successfully used with the following components in the following versions:

1.  PostgreSQL:
-   11.x (checked: 11.18), with an extra installation step
-   12.x (checked: 12.13), with an extra installation step
-   13.x (checked: 13.9)
-   14.x (checked: 14.1)
-   15.x (checked: 15.1, 15.3)
-   16.x (checked: 16.0)

2.  Perl:
-   v5.20.3
-   v5.34.0

3.  Postfix (<https://www.postfix.org/>):
-   3.6.5

4.  Cyrus IMAP (<https://www.cyrusimap.org/>) (CalDAV module):
-   3.6.0

Other versions may also work.

## ChangeLog ##

For a summary of changes, refer to the `ChangeLog` file in the package.

## WARNING ##

This repository is for testing purposes.
The code here may not work properly or even compile.
As for now, use the official packages from SourceForge.

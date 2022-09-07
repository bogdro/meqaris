# Meqaris Makefile
#
# Copyright (C) 2022 Bogdan 'bogdro' Drozdowski, bogdro (at) users . sourceforge . net
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

NAME = meqaris
VER = 1.2

RMDIR = /bin/rm -fr
# when using '-p', no error is generated when the directory exists
MKDIR = /bin/mkdir -p
COPY = /bin/cp -pRf
CHMOD = /bin/chmod

# Use the GNU tar format
# ifneq ($(shell tar --version | grep -i bsd),)
# PACK1_GNUOPTS = --format gnutar
# endif
PACK1 = /bin/tar $(PACK1_GNUOPTS) -vcf
PACK1_EXT = .tar

PACK2 = /usr/bin/gzip -9
PACK2_EXT = .gz

SUBDIRS = bin config manual scripts sql

all:	dist

dist:	$(NAME)-$(VER)$(PACK1_EXT)$(PACK2_EXT)

$(NAME)-$(VER)$(PACK1_EXT)$(PACK2_EXT): AUTHORS ChangeLog COPYING NEWS \
		README INSTALL-Meqaris.txt Makefile meqaris.spec \
		meqaris.spec $(shell find $(SUBDIRS) -type f)
	$(RMDIR) $(NAME)-$(VER)
	$(MKDIR) $(NAME)-$(VER)
	$(COPY) AUTHORS ChangeLog COPYING INSTALL-Meqaris.txt NEWS \
		README Makefile meqaris.spec \
		$(SUBDIRS) $(NAME)-$(VER)
	$(PACK1) $(NAME)-$(VER)$(PACK1_EXT) $(NAME)-$(VER)
	$(PACK2) $(NAME)-$(VER)$(PACK1_EXT)
	$(RMDIR) $(NAME)-$(VER)

install:
	$(MKDIR) $(BINDIR)
	$(MKDIR) $(CONFDIR)
	$(MKDIR) $(DOCDIR)/$(NAME)
	$(MKDIR) $(DATADIR)/$(NAME)/sql
	$(CHMOD) 755 $(BINDIR) $(CONFDIR) $(DATADIR)/$(NAME) $(DATADIR)/$(NAME)/sql
	$(COPY) bin/meqaris $(BINDIR)
	$(CHMOD) 755 $(BINDIR)/meqaris
	$(COPY) sql/*.pgsql $(DATADIR)/$(NAME)/sql
	$(CHMOD) 644 $(DATADIR)/$(NAME)/sql/*.pgsql
	$(COPY) config/meqaris-log4perl.cfg $(DATADIR)/$(NAME)/
	$(CHMOD) 644 $(DATADIR)/$(NAME)/meqaris-log4perl.cfg
	$(COPY) manual AUTHORS ChangeLog COPYING INSTALL-Meqaris.txt \
		README $(DOCDIR)/$(NAME)/
	$(CHMOD) 644 $(DOCDIR)/$(NAME)/manual/en/*.*
	$(CHMOD) 644 $(DOCDIR)/$(NAME)/manual/en/rsrc/*.*
	$(CHMOD) 644 $(DOCDIR)/$(NAME)/manual/rsrc/*.*
	$(CHMOD) 644 $(DOCDIR)/$(NAME)/manual/rsrc/css/*.*
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual/en
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual/en/rsrc
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual/rsrc
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual/rsrc/css
	$(COPY) config/meqaris.ini $(CONFDIR)/
	$(CHMOD) 644 $(CONFDIR)/meqaris.ini

.PHONY: all dist install

# Meqaris Makefile
#
# Copyright (C) 2022-2025 Bogdan 'bogdro' Drozdowski, bogdro (at) users . sourceforge . net
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
VER = 2.0

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

POD2MAN = /usr/bin/pod2man
POD2CHK = /usr/bin/podchecker

SUBDIRS = bin config docker manual scripts sql test

EXTRA_DIST = AUTHORS ChangeLog COPYING INSTALL-Meqaris.txt NEWS \
	Makefile $(NAME).pod $(NAME).spec README

ifeq ($(BINDIR),)
BINDIR = /usr/bin
endif

ifeq ($(CONFDIR),)
CONFDIR = /etc
endif

ifeq ($(DOCDIR),)
DOCDIR = /usr/share/doc
endif

ifeq ($(DATADIR),)
DATADIR = /var/lib
endif

ifeq ($(MANDIR),)
MANDIR = /usr/share/man
endif

all:	dist

dist:	$(NAME)-$(VER)$(PACK1_EXT)$(PACK2_EXT)

$(NAME)-$(VER)$(PACK1_EXT)$(PACK2_EXT): $(EXTRA_DIST) \
		$(shell find $(SUBDIRS) -type f)
	$(RMDIR) $(NAME)-$(VER)
	$(MKDIR) $(NAME)-$(VER)
	$(COPY) $(EXTRA_DIST) $(SUBDIRS) $(NAME)-$(VER)
	$(RMDIR) $(NAME)-$(VER)/test/meqaris-log4perl-test.cfg
	$(RMDIR) $(NAME)-$(VER)/test/meqaris-test.ini
	$(RMDIR) $(NAME)-$(VER)/test/*.log
	$(RMDIR) $(NAME)-$(VER)$(PACK1_EXT)$(PACK2_EXT)
	$(PACK1) $(NAME)-$(VER)$(PACK1_EXT) $(NAME)-$(VER)
	$(PACK2) $(NAME)-$(VER)$(PACK1_EXT)
	$(RMDIR) $(NAME)-$(VER)

install:
	$(MKDIR) $(BINDIR)
	$(MKDIR) $(CONFDIR)/logrotate.d
	$(MKDIR) $(DOCDIR)/$(NAME)
	$(MKDIR) $(DATADIR)/$(NAME)/sql
	$(MKDIR) $(MANDIR)/man1
	$(CHMOD) 755 $(BINDIR) $(CONFDIR) $(CONFDIR)/logrotate.d \
		$(DATADIR)/$(NAME) $(DATADIR)/$(NAME)/sql
	$(COPY) bin/$(NAME) $(BINDIR)
	$(CHMOD) 755 $(BINDIR)/$(NAME)
	$(COPY) sql/*.pgsql $(DATADIR)/$(NAME)/sql
	$(CHMOD) 644 $(DATADIR)/$(NAME)/sql/*.pgsql
	$(COPY) config/$(NAME)-log4perl.cfg $(DATADIR)/$(NAME)/
	$(CHMOD) 644 $(DATADIR)/$(NAME)/$(NAME)-log4perl.cfg
	$(COPY) manual AUTHORS ChangeLog COPYING INSTALL-Meqaris.txt \
		README $(DOCDIR)/$(NAME)/
	$(POD2CHK) $(NAME).pod
	$(POD2MAN) $(NAME).pod $(MANDIR)/man1/$(NAME).1
	#$(PACK2) $(MANDIR)/man1/$(NAME).1
	$(CHMOD) 644 $(DOCDIR)/$(NAME)/manual/en/*.*
	$(CHMOD) 644 $(DOCDIR)/$(NAME)/manual/en/rsrc/*.*
	$(CHMOD) 644 $(DOCDIR)/$(NAME)/manual/rsrc/*.*
	$(CHMOD) 644 $(DOCDIR)/$(NAME)/manual/rsrc/css/*.*
	$(CHMOD) 755 $(DOCDIR)/$(NAME)
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual/en
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual/en/rsrc
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual/rsrc
	$(CHMOD) 755 $(DOCDIR)/$(NAME)/manual/rsrc/css
	$(COPY) config/$(NAME).ini $(CONFDIR)/
	$(CHMOD) 644 $(CONFDIR)/$(NAME).ini
	$(COPY) config/$(NAME).logrotate $(CONFDIR)/logrotate.d/$(NAME)
	$(CHMOD) 644 $(CONFDIR)/logrotate.d/$(NAME)

uninstall:
	$(RMDIR) $(BINDIR)/$(NAME)
	$(RMDIR) $(CONFDIR)/$(NAME).ini
	$(RMDIR) $(CONFDIR)/logrotate.d/$(NAME)
	$(RMDIR) $(DOCDIR)/$(NAME)
	$(RMDIR) $(DATADIR)/$(NAME)
	$(RMDIR) $(MANDIR)/man1/$(NAME).1*

check:
	cd test && ./test-suite.sh

.PHONY: all dist install uninstall check

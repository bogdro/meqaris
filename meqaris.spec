# Special names here like {__make} come from /usr/lib/rpm/macros, /usr/lib/rpm/macros.rpmbuild

%define meq_version 1.1
%define meq_release 1
%define meq_name meqaris
%define meq_url https://meqaris.sourceforge.io
%define meq_lic AGPLv3
%define meq_summary System for booking meeting resources
%define meq_descr Meqaris (Meeting Equipment and Room Invitation System)\
is a system that allows booking meeting rooms and other resources (like\
mobile whiteboards, projectors or conference sets) using the same e-mail\
invitations that are used to invite participants to meetings.

%define _unpackaged_files_terminate_build 0
%define _enable_debug_packages 0

Summary:	%{meq_summary}
Name:		%{meq_name}
Version:	%{meq_version}
Release:	%{meq_release}
URL:		%{meq_url}
BugURL:		%{meq_url}
License:	%{meq_lic}
# group must be one of the listed in /usr/share/doc/rpm-.../GROUPS or /usr/share/rpmlint/config.d/*.conf
Group:		Networking/Mail
Source:		%{meq_name}-%{meq_version}.tar.gz
#BuildRoot:	{_tmppath}/{meq_name}-build
Requires:	perl(DBD::Pg)
BuildArch:	noarch
BuildRequires:	make

%description
%{meq_descr}

%prep
%setup -q

%build

%post
%__mkdir_p /var/log/
touch /var/log/meqaris.log
%__chmod 666 /var/log/meqaris.log

#postun

%install

%make_build install \
	BINDIR=%{buildroot}/%{_bindir} \
	CONFDIR=%{buildroot}/%{_sysconfdir} \
	DATADIR=%{buildroot}/var/lib \
	DOCDIR=%{buildroot}/%{_datadir}/doc

%clean

%{__rm} -rf %{buildroot}

%files

%defattr(-,root,root)
%{_bindir}/meqaris
%config(noreplace) %attr(644,-,-) %{_sysconfdir}/meqaris.ini
%doc README
%doc COPYING
%doc AUTHORS
%doc ChangeLog
%doc INSTALL-Meqaris.txt
%doc manual
# attr(777,-,-)
%dir /var/lib/meqaris
%dir /var/lib/meqaris/sql
%attr(644,-,-) /var/lib/meqaris/sql/*
%config(noreplace) %attr(644,-,-) /var/lib/meqaris/meqaris-log4perl.cfg
%ghost /var/log/meqaris.log

%changelog

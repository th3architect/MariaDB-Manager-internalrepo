%define _topdir	 	%(echo $PWD)/
%define name		MariaDB-Manager-internalrepo
%define release         ##RELEASE_TAG##
%define version         ##VERSION_TAG##
%define install_path	/var/www/html/repo/

BuildRoot:		%{buildroot}
Summary: 		SkySQL repository
License: 		GPL
Name: 			%{name}
Version: 		%{version}
Release: 		%{release}
Source: 		%{name}-%{version}-%{release}.tar.gz
Prefix: 		/
Group: 			Development/Tools
#Requires:
Obsoletes:		MariaDB-Manager-repo
#BuildRequires:		

%description
Creates repository with all packages for Galera node

%prep

%setup -q

%build

%post
if [ ! -h %{install_path}CentOS/6Server ]; then 
	ln -s %{install_path}CentOS/6 %{install_path}CentOS/6Server
fi

%posttrans
if [ ! -h %{install_path}CentOS6_64 ]; then
	ln -s %{install_path}CentOS/6/x86_64/ %{install_path}CentOS6_64
fi

%install

mkdir -p $RPM_BUILD_ROOT%{install_path}CentOS
cp -r 6 $RPM_BUILD_ROOT%{install_path}CentOS

mkdir -p $RPM_BUILD_ROOT%{install_path}dist
cp -r dist/* $RPM_BUILD_ROOT%{install_path}dist

%clean


%files
%defattr(-,root,root)
%{install_path}CentOS/*
%{install_path}dist/*

%changelog

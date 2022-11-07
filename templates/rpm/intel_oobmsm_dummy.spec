%define module _MODULE_NAME_
%define version _VERSION_
%define release _RELEASE_

%define _rpmdir ./

Name:		%{module}
Version:	%{version}
Release:	%{release}
BuildArch:	noarch
Vendor:		Intel
Summary:	Intel® Out-of-Band Management Services Module Fallback Driver
License:	GPL-2.0
Requires:	dkms bash tar sed
Source0:	%{module}-%{version}-%{release}-src.tar.gz

%description
Intel® Out-of-Band Management Services Module Fallback Driver to provide a set of essential driver callbacks.

%files
%defattr (-, root, root)
/usr/src/%{module}-%{version}-%{release}/
/usr/share/doc/%{module}/LICENSE

%prep
%setup -c -n %{module}-%{version}-%{release}

%install
mkdir -p %{buildroot}/usr/src/%{module}-%{version}-%{release}/
cp -rf * %{buildroot}/usr/src/%{module}-%{version}-%{release}
mkdir -p %{buildroot}/usr/share/doc/%{module}/
cp -rf LICENSE %{buildroot}/usr/share/doc/%{module}/LICENSE

%post
occurrences=`/usr/sbin/dkms status | grep "%{module}" | grep %{version}-%{release} | wc -l`
if [ ! occurrences > 0 ];
then
    /usr/sbin/dkms add -m %{module} -v %{version}-%{release}
fi
/usr/sbin/dkms build -m %{module} -v %{version}-%{release}
/usr/sbin/dkms install -m %{module} -v %{version}-%{release}
exit 0

%preun
/usr/sbin/dkms remove -m %{module} -v %{version}-%{release} --all --rpm_safe_upgrade
exit 0

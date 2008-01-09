Summary:	input preprocessor for less
Name:		lesspipe
Version:	1.0
Release:	2
License:	GPL v2
Group:		Applications/Text
Source0:	%{name}.sh
BuildRequires:	rpmbuild(macros) >= 1.316
Requires:	file
Conflicts:	less < 394-7.1
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
input preprocessor for less.

Before less opens a file, it first gives your input preprocessor a
chance to modify the way the contents of the file are displayed.

This package contains PLD Linux script to display various archive
contents in human readable way.

%prep

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{_bindir},/etc/env.d}
install %{SOURCE0}  $RPM_BUILD_ROOT%{_bindir}

# Prepare env file
cat > $RPM_BUILD_ROOT/etc/env.d/LESSOPEN <<'EOF'
LESSOPEN="|lesspipe.sh %s"
EOF

%clean
rm -rf $RPM_BUILD_ROOT

%post
%env_update

%postun
%env_update

%files
%defattr(644,root,root,755)
%attr(755,root,root) %{_bindir}/%{name}.sh
%config(noreplace,missingok) %verify(not md5 mtime size) /etc/env.d/*
